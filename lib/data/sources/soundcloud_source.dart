import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/song_model.dart';
import 'music_source.dart';

class SoundcloudSource implements MusicSource {
  // Stream URL cache: sourceId -> (url, fetchedAt)
  final Map<String, _CachedStreamUrl> _streamCache = {};

  @override
  String get sourceName => AppConstants.sourceSoundcloud;

  /// SoundCloud client_id loaded from .env, falling back to placeholder.
  String get _clientId {
    try {
      return dotenv.env['SOUNDCLOUD_CLIENT_ID'] ?? 'YOUR_SOUNDCLOUD_CLIENT_ID';
    } catch (_) {
      return 'YOUR_SOUNDCLOUD_CLIENT_ID';
    }
  }

  @override
  Future<List<SongModel>> search(String query, {int limit = 20}) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.soundcloudBaseUrl}/tracks'
        '?q=${Uri.encodeComponent(query)}'
        '&client_id=$_clientId'
        '&limit=$limit',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> tracks = json.decode(response.body);

        // Filter out non-streamable tracks (geo-restricted or private)
        return tracks
            .where((t) => t['streamable'] == true)
            .map((t) => _parseTrack(t as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[SoundCloud] Search error: $e');
    }
    return [];
  }

  @override
  Future<String?> getStreamUrl(String sourceId) async {
    // Check cache first
    final cached = _streamCache[sourceId];
    if (cached != null && !cached.isExpired) {
      return cached.url;
    }

    try {
      // SoundCloud /stream endpoint redirects to the actual audio URL.
      // We return the redirect-capable URL; just_audio follows redirects.
      final url =
          '${AppConstants.soundcloudBaseUrl}/tracks/$sourceId/stream?client_id=$_clientId';

      // Cache the URL
      _streamCache[sourceId] = _CachedStreamUrl(
        url: url,
        fetchedAt: DateTime.now(),
      );

      return url;
    } catch (e) {
      debugPrint('[SoundCloud] Stream URL error: $e');
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
  }

  SongModel _parseTrack(Map<String, dynamic> track) {
    return SongModel(
      title: track['title'] ?? 'Unknown Title',
      artist: track['user']?['username'] ?? 'Unknown Artist',
      album: 'SoundCloud',
      durationMs: (track['duration'] as int? ?? 0), // already in ms
      filePath: '', // No local file path
      dateAdded: DateTime.now(),
      source: AppConstants.sourceSoundcloud,
      sourceId: track['id']?.toString(),
      streamUrl: null, // will be fetched via getStreamUrl
      thumbnailUrl:
          track['artwork_url']?.toString().replaceAll('large', 't500x500'),
    );
  }
}

/// Internal class to hold a cached stream URL with its fetch timestamp.
class _CachedStreamUrl {
  final String url;
  final DateTime fetchedAt;

  _CachedStreamUrl({required this.url, required this.fetchedAt});

  /// SoundCloud stream URLs are relatively stable but we cache with
  /// the configured duration (default 5 hours) for consistency.
  bool get isExpired =>
      DateTime.now().difference(fetchedAt) > AppConstants.streamCacheDuration;
}
