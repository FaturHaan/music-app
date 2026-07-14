import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsService {
  static const String _lyricsOvhBaseUrl = 'https://api.lyrics.ovh/v1';
  static const String _lyricsaltBaseUrl = 'https://lyrist.vercel.app/api';

  // In-memory cache: "artist|title" -> lyrics text
  final Map<String, String?> _cache = {};

  Future<String?> getLyrics(String artist, String title) async {
    final cacheKey = _buildCacheKey(artist, title);

    // Return cached result if available
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    // Try primary source: lyrics.ovh
    String? lyrics = await _fetchFromLyricsOvh(artist, title);

    // Fallback: lyrist.vercel.app
    if (lyrics == null || lyrics.trim().isEmpty) {
      lyrics = await _fetchFromLyrist(artist, title);
    }

    // Cache the result (even null, to avoid repeated failed lookups)
    _cache[cacheKey] = lyrics;

    return lyrics;
  }

  /// Primary lyrics source: lyrics.ovh
  Future<String?> _fetchFromLyricsOvh(String artist, String title) async {
    try {
      final uri = Uri.parse(
          '$_lyricsOvhBaseUrl/${Uri.encodeComponent(artist)}/${Uri.encodeComponent(title)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lyrics = data['lyrics'] as String?;
        if (lyrics != null && lyrics.trim().isNotEmpty) {
          return lyrics;
        }
      }
    } catch (_) {
      // Fall through to return null
    }
    return null;
  }

  /// Fallback lyrics source: lyrist.vercel.app
  Future<String?> _fetchFromLyrist(String artist, String title) async {
    try {
      final uri = Uri.parse(
          '$_lyricsaltBaseUrl/${Uri.encodeComponent(artist)}/${Uri.encodeComponent(title)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lyrics = data['lyrics'] as String?;
        if (lyrics != null && lyrics.trim().isNotEmpty) {
          return lyrics;
        }
      }
    } catch (_) {
      // Fall through to return null
    }
    return null;
  }

  String _buildCacheKey(String artist, String title) {
    return '${artist.toLowerCase().trim()}|${title.toLowerCase().trim()}';
  }

  /// Clear all cached lyrics
  void clearCache() {
    _cache.clear();
  }
}
