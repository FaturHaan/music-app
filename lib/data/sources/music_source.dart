import '../models/song_model.dart';

abstract class MusicSource {
  /// Unique identifier for this source (e.g., 'jamendo', 'itunes')
  String get sourceName;

  /// Search for songs matching the query
  Future<List<SongModel>> search(String query, {int limit = 20});

  /// Get the direct stream URL for a specific song ID
  /// Returns null if not supported or not found
  Future<String?> getStreamUrl(String sourceId);
}
