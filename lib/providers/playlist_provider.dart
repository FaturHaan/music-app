import 'package:flutter/foundation.dart';
import '../data/models/playlist_model.dart';
import '../data/repositories/playlist_repository.dart';

class PlaylistProvider extends ChangeNotifier {
  final PlaylistRepository _playlistRepository;

  PlaylistProvider(this._playlistRepository);

  List<PlaylistModel> _playlists = [];
  bool _isLoading = false;

  List<PlaylistModel> get playlists => _playlists;
  bool get isLoading => _isLoading;

  Future<void> loadPlaylists() async {
    _isLoading = true;
    notifyListeners();

    try {
      _playlists = await _playlistRepository.getAllPlaylists();
    } catch (e) {
      debugPrint('Failed to load playlists: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    await _playlistRepository.createPlaylist(name);
    await loadPlaylists();
  }

  Future<void> deletePlaylist(int playlistId) async {
    await _playlistRepository.deletePlaylist(playlistId);
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  Future<void> renamePlaylist(int playlistId, String newName) async {
    await _playlistRepository.updatePlaylistName(playlistId, newName);
    await loadPlaylists();
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    await _playlistRepository.addSongToPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await _playlistRepository.removeSongFromPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<PlaylistModel?> getPlaylistById(int id) async {
    return await _playlistRepository.getPlaylistById(id);
  }
}
