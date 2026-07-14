import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/models/song_model.dart';
import '../data/repositories/song_repository.dart';
import '../data/services/storage_service.dart';
import '../data/services/metadata_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/enrichment_service.dart';

enum LibraryFilter { all, favorites }
enum LibrarySort { dateAdded, title, artist, album }

class LibraryProvider extends ChangeNotifier {
  final SongRepository _songRepository;
  final StorageService _storageService;
  final MetadataService _metadataService;
  final EnrichmentService _enrichmentService;

  LibraryProvider(
    this._songRepository,
    this._storageService,
    this._metadataService,
    this._enrichmentService,
  );

  List<SongModel> _songs = [];
  List<SongModel> _favoriteSongs = [];
  List<SongModel> _onlineFavorites = [];
  bool _isLoading = false;
  bool _isImporting = false;
  String? _error;

  LibraryFilter _filter = LibraryFilter.all;
  LibrarySort _sort = LibrarySort.dateAdded;

  List<SongModel> get songs => _songs;
  List<SongModel> get favoriteSongs => _favoriteSongs;
  List<SongModel> get onlineFavorites => _onlineFavorites;
  bool get isLoading => _isLoading;
  bool get isImporting => _isImporting;
  String? get error => _error;
  LibraryFilter get filter => _filter;
  LibrarySort get sort => _sort;

  static const String _filterKey = 'library_filter';
  static const String _sortKey = 'library_sort';

  Future<void> loadSongs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final filterIndex = prefs.getInt(_filterKey) ?? LibraryFilter.all.index;
      final sortIndex = prefs.getInt(_sortKey) ?? LibrarySort.dateAdded.index;
      
      _filter = LibraryFilter.values[filterIndex];
      _sort = LibrarySort.values[sortIndex];

      _songs = await _songRepository.getAllSongs();
      _favoriteSongs = await _songRepository.getFavoriteSongs();
      _onlineFavorites = await _songRepository.getOnlineFavorites();
    } catch (e) {
      _error = 'Failed to load songs: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> importSongs() async {
    try {
      // Check and request permission
      final status = await Permission.audio.request();
      if (!status.isGranted) {
        // Try storage permission for older Android
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          _error = 'Storage permission denied';
          notifyListeners();
          return;
        }
      }

      // Pick files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      _isImporting = true;
      _error = null;
      notifyListeners();

      for (final file in result.files) {
        if (file.path == null) continue;

        try {
          // 1. Copy file to app directory
          final newPath = await _storageService.copyAudioFile(file.path!);

          // 2. Extract metadata
          final metadata = await _metadataService.extractMetadata(newPath);

          // 3. Save cover art if available
          String? coverArtPath;
          if (metadata.coverArtBytes != null) {
            coverArtPath = await _storageService.saveCoverArt(
              metadata.coverArtBytes!,
            );
          }

          // 4. Create song model
          SongModel song = SongModel(
            filePath: newPath,
            title: metadata.title,
            artist: metadata.artist,
            album: metadata.album,
            durationMs: metadata.durationMs,
            coverArtPath: coverArtPath,
            dateAdded: DateTime.now(),
          );

          // 5. Enrich with online data
          song = await _enrichmentService.enrichLocalSong(song);

          // 6. Insert into database
          await _songRepository.insertSong(song);
        } catch (e) {
          debugPrint('Failed to import ${file.name}: $e');
        }
      }

      // Refresh songs list
      await loadSongs();
    } catch (e) {
      _error = 'Import failed: $e';
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(SongModel song) async {
    final newFavorite = !song.isFavorite;
    await _songRepository.toggleFavorite(song.id!, newFavorite);

    // Update local lists
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      _songs[index] = song.copyWith(isFavorite: newFavorite);
    }

    if (newFavorite) {
      _favoriteSongs.insert(0, song.copyWith(isFavorite: true));
    } else {
      _favoriteSongs.removeWhere((s) => s.id == song.id);
    }

    notifyListeners();
  }

  Future<void> deleteSong(SongModel song) async {
    await _songRepository.deleteSong(song.id!);

    // Delete files
    await _storageService.deleteFile(song.filePath);
    if (song.coverArtPath != null) {
      await _storageService.deleteFile(song.coverArtPath!);
    }

    _songs.removeWhere((s) => s.id == song.id);
    _favoriteSongs.removeWhere((s) => s.id == song.id);
    notifyListeners();
  }

  Future<void> setFilter(LibraryFilter filter) async {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_filterKey, filter.index);
  }

  Future<void> setSort(LibrarySort sort) async {
    if (_sort == sort) return;
    _sort = sort;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sortKey, sort.index);
  }
}
