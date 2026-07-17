import 'package:flutter/foundation.dart';

/// Represents a music genre with its display properties.
class Genre {
  final String name;
  final int color1;
  final int color2;

  const Genre({required this.name, required this.color1, required this.color2});
}

class DiscoveryProvider extends ChangeNotifier {
  DiscoveryProvider();

  List<Genre> _genres = [];
  bool _isLoading = false;
  String? _error;

  List<Genre> get genres => _genres;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDiscoverData() async {
    _error = null;
    _isLoading = false;
    loadGenres();
  }

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
}
