import '../models/song_model.dart';
import 'music_source.dart';

class SourceAggregator {
  final List<MusicSource> _sources;

  SourceAggregator(this._sources);

  /// Search across all sources in parallel
  Future<List<SongModel>> searchAll(String query, {int limitPerSource = 15}) async {
    if (query.trim().isEmpty) return [];

    final List<Future<List<SongModel>>> futures = _sources.map(
      (source) => source.search(query, limit: limitPerSource).catchError((_) => <SongModel>[])
    ).toList();

    try {
      final List<List<SongModel>> results = await Future.wait(futures);
      
      // Combine results
      final List<SongModel> combinedResults = [];
      for (final resultList in results) {
        combinedResults.addAll(resultList);
      }

      // Deduplicate by normalized title + artist
      return _deduplicateResults(combinedResults);
    } catch (e) {
      return [];
    }
  }

  /// Remove duplicate songs based on normalized title + artist.
  /// Keeps the first occurrence (which preserves source ordering priority).
  List<SongModel> _deduplicateResults(List<SongModel> songs) {
    final seen = <String>{};
    final deduped = <SongModel>[];

    for (final song in songs) {
      final key = _normalizeKey(song.title, song.artist);
      if (seen.add(key)) {
        deduped.add(song);
      }
    }

    return deduped;
  }

  /// Create a normalized key for deduplication.
  /// Strips whitespace, lowercases, and removes common suffixes like "(Official Video)".
  String _normalizeKey(String title, String artist) {
    final normalizedTitle = title
        .toLowerCase()
        .replaceAll(RegExp(r'\(.*?\)'), '') // Remove parenthetical info
        .replaceAll(RegExp(r'\[.*?\]'), '') // Remove bracketed info
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');   // Collapse whitespace

    final normalizedArtist = artist
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');

    return '$normalizedTitle|$normalizedArtist';
  }

  /// Get stream URL by finding the source and asking it for the stream URL
  Future<String?> getStreamUrl(String sourceName, String sourceId) async {
    for (final source in _sources) {
      if (source.sourceName == sourceName) {
        return source.getStreamUrl(sourceId);
      }
    }
    return null;
  }
}
