import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/song_model.dart';
import 'music_source.dart';

class JamendoSource implements MusicSource {
  @override
  String get sourceName => AppConstants.sourceJamendo;

  @override
  Future<List<SongModel>> search(String query, {int limit = 20}) async {
    if (AppConstants.jamendoClientId == 'YOUR_JAMENDO_CLIENT_ID') {
      return []; // Return empty if no client ID is set
    }

    try {
      final uri = Uri.parse(
          '${AppConstants.jamendoBaseUrl}/tracks/?client_id=${AppConstants.jamendoClientId}&format=json&limit=$limit&search=$query&include=musicinfo');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results.map((track) => _parseJamendoTrack(track)).toList();
        }
      }
    } catch (e) {
      // Ignore errors and return empty list
    }
    return [];
  }

  @override
  Future<String?> getStreamUrl(String sourceId) async {
    if (AppConstants.jamendoClientId == 'YOUR_JAMENDO_CLIENT_ID') {
      return null;
    }
    return '${AppConstants.jamendoBaseUrl}/tracks/file/?client_id=${AppConstants.jamendoClientId}&id=$sourceId';
  }

  Future<List<SongModel>> getTrending({int limit = 20}) async {
    if (AppConstants.jamendoClientId == 'YOUR_JAMENDO_CLIENT_ID') {
      return [];
    }
    try {
      final uri = Uri.parse(
          '${AppConstants.jamendoBaseUrl}/tracks/?client_id=${AppConstants.jamendoClientId}&format=json&limit=$limit&order=popularity_week&include=musicinfo');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results.map((track) => _parseJamendoTrack(track)).toList();
        }
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  Future<List<SongModel>> getNewReleases({int limit = 20}) async {
    if (AppConstants.jamendoClientId == 'YOUR_JAMENDO_CLIENT_ID') {
      return [];
    }
    try {
      final uri = Uri.parse(
          '${AppConstants.jamendoBaseUrl}/tracks/?client_id=${AppConstants.jamendoClientId}&format=json&limit=$limit&order=releasedate_desc&include=musicinfo');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results.map((track) => _parseJamendoTrack(track)).toList();
        }
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  SongModel _parseJamendoTrack(Map<String, dynamic> track) {
    final int duration = (track['duration'] as int? ?? 0) * 1000;
    
    return SongModel(
      title: track['name'] ?? 'Unknown Title',
      artist: track['artist_name'] ?? 'Unknown Artist',
      album: track['album_name'] ?? 'Unknown Album',
      durationMs: duration,
      filePath: '', // No local file path yet
      dateAdded: DateTime.now(),
      source: AppConstants.sourceJamendo,
      sourceId: track['id'],
      streamUrl: track['audio'],
      thumbnailUrl: track['image'],
    );
  }
}
