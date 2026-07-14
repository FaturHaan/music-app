import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/song_model.dart';
import 'music_source.dart';

class ItunesSource implements MusicSource {
  @override
  String get sourceName => AppConstants.sourceItunes;

  @override
  Future<List<SongModel>> search(String query, {int limit = 20}) async {
    try {
      final uri = Uri.parse(
          '${AppConstants.itunesBaseUrl}/search?term=${Uri.encodeComponent(query)}&media=music&entity=song&limit=$limit');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results.map((track) => _parseItunesTrack(track)).toList();
        }
      }
    } catch (e) {
      // Ignore errors and return empty list
    }
    return [];
  }

  @override
  Future<String?> getStreamUrl(String sourceId) async {
    // iTunes preview URLs are usually retrieved during search
    // We don't have a direct endpoint just to get a stream URL by ID without search
    // If needed, we could use the lookup endpoint:
    try {
      final uri = Uri.parse('${AppConstants.itunesBaseUrl}/lookup?id=$sourceId');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['previewUrl'];
        }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  SongModel _parseItunesTrack(Map<String, dynamic> track) {
    // Get highest resolution artwork
    String? artworkUrl = track['artworkUrl100'];
    if (artworkUrl != null) {
      artworkUrl = artworkUrl.replaceAll('100x100bb', '600x600bb');
    }

    return SongModel(
      title: track['trackName'] ?? 'Unknown Title',
      artist: track['artistName'] ?? 'Unknown Artist',
      album: track['collectionName'] ?? 'Unknown Album',
      durationMs: track['trackTimeMillis'] ?? 30000, // Preview is typically 30s
      filePath: '', // No local file path yet
      dateAdded: DateTime.now(),
      source: AppConstants.sourceItunes,
      sourceId: track['trackId']?.toString(),
      streamUrl: track['previewUrl'],
      thumbnailUrl: artworkUrl,
    );
  }
}
