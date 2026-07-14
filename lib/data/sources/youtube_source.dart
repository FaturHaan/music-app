import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../core/constants/app_constants.dart';
import '../models/song_model.dart';
import 'music_source.dart';

class YoutubeSource implements MusicSource {
  final _yt = YoutubeExplode();

  // Stream URL cache: sourceId -> (url, fetchedAt)
  final Map<String, _CachedStreamUrl> _streamCache = {};

  @override
  String get sourceName => AppConstants.sourceYoutube;

  @override
  Future<List<SongModel>> search(String query, {int limit = 20}) async {
    try {
      final searchResults = await _yt.search.search(query);
      final results = searchResults.take(limit).toList();

      return results.map((video) {
        return SongModel(
          title: video.title,
          artist: video.author,
          album: 'YouTube',
          durationMs: video.duration?.inMilliseconds ?? 0,
          filePath: '', // No local file path
          dateAdded: DateTime.now(),
          source: AppConstants.sourceYoutube,
          sourceId: video.id.value,
          thumbnailUrl: video.thumbnails.highResUrl.toString(),
        );
      }).toList();
    } catch (e) {
      // Ignore errors and return empty list
      return [];
    }
  }

  @override
  Future<String?> getStreamUrl(String sourceId) async {
    // Check cache first
    final cached = _streamCache[sourceId];
    if (cached != null && !cached.isExpired) {
      return cached.url;
    }

    // Fetch fresh stream URL
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(sourceId);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      final url = streamInfo.url.toString();

      // Cache the URL
      _streamCache[sourceId] = _CachedStreamUrl(
        url: url,
        fetchedAt: DateTime.now(),
      );

      return url;
    } catch (e) {
      // If cached URL exists but expired, try using it as fallback
      if (cached != null) {
        return cached.url;
      }
      return null;
    }
  }

  /// Clear all cached stream URLs
  void clearCache() {
    _streamCache.clear();
  }

  /// Remove expired entries from cache
  void pruneCache() {
    _streamCache.removeWhere((_, cached) => cached.isExpired);
  }

  void dispose() {
    _streamCache.clear();
    _yt.close();
  }
}

/// Internal class to hold a cached stream URL with its fetch timestamp.
class _CachedStreamUrl {
  final String url;
  final DateTime fetchedAt;

  _CachedStreamUrl({required this.url, required this.fetchedAt});

  /// YouTube stream URLs typically expire after ~6 hours.
  /// We use the configured cache duration (default 5 hours) to be safe.
  bool get isExpired =>
      DateTime.now().difference(fetchedAt) > AppConstants.streamCacheDuration;
}
