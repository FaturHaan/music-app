import 'package:flutter/foundation.dart';
import '../data/models/song_model.dart';
import '../data/sources/jamendo_source.dart';

/// Represents a music genre with its display properties.
class Genre {
  final String name;
  final int color1;
  final int color2;

  const Genre({required this.name, required this.color1, required this.color2});
}

class DiscoveryProvider extends ChangeNotifier {
  final JamendoSource _jamendoSource;

  DiscoveryProvider(this._jamendoSource);

  List<SongModel> _trending = [];
  List<SongModel> _newReleases = [];
  List<Genre> _genres = [];
  bool _isLoadingTrending = false;
  bool _isLoadingNewReleases = false;
  String? _error;

  List<SongModel> get trending => _trending;
  List<SongModel> get newReleases => _newReleases;
  List<Genre> get genres => _genres;
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingNewReleases => _isLoadingNewReleases;
  String? get error => _error;

  Future<void> loadDiscoverData() async {
    _error = null;
    notifyListeners();

    await Future.wait([
      _loadTrending(),
      _loadNewReleases(),
    ]);

    // Load genres synchronously (static data)
    loadGenres();
  }

  /// Load available music genres.
  /// Currently uses a curated static list; can be replaced with an API call
  /// if a genre endpoint becomes available.
  void loadGenres() {
    _genres = const [
      Genre(name: 'Pop', color1: 0xFFFF4B2B, color2: 0xFFFF416C),
      Genre(name: 'Rock', color1: 0xFF1CB5E0, color2: 0xFF000046),
      Genre(name: 'Jazz', color1: 0xFFFDC830, color2: 0xFFF37335),
      Genre(name: 'Electronic', color1: 0xFF00B4DB, color2: 0xFF0083B0),
      Genre(name: 'Hip Hop', color1: 0xFF8E2DE2, color2: 0xFF4A00E0),
      Genre(name: 'Classical', color1: 0xFF56AB2F, color2: 0xFFA8E063),
      Genre(name: 'R&B', color1: 0xFFE44D26, color2: 0xFFF16529),
      Genre(name: 'Country', color1: 0xFFDA4453, color2: 0xFF89216B),
      Genre(name: 'Metal', color1: 0xFF2C3E50, color2: 0xFF4CA1AF),
      Genre(name: 'Reggae', color1: 0xFF11998E, color2: 0xFF38EF7D),
    ];
    notifyListeners();
  }

  Future<void> _loadTrending() async {
    _isLoadingTrending = true;
    notifyListeners();

    try {
      _trending = await _jamendoSource.getTrending(limit: 15);
    } catch (e) {
      _error = 'Failed to load trending: $e';
    }

    _isLoadingTrending = false;
    notifyListeners();
  }

  Future<void> _loadNewReleases() async {
    _isLoadingNewReleases = true;
    notifyListeners();

    try {
      _newReleases = await _jamendoSource.getNewReleases(limit: 15);
    } catch (e) {
      _error = 'Failed to load new releases: $e';
    }

    _isLoadingNewReleases = false;
    notifyListeners();
  }
}
