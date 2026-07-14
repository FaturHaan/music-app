import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class MetadataResult {
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final List<int>? coverArtBytes;

  const MetadataResult({
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    this.coverArtBytes,
  });
}

class MetadataService {
  /// Extract metadata from an audio file
  Future<MetadataResult> extractMetadata(String filePath) async {
    try {
      final file = File(filePath);
      final metadata = readMetadata(file, getImage: true);

      final fileName = file.uri.pathSegments.last;
      final nameWithoutExt = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;

      // Extract cover art bytes
      List<int>? coverBytes;
      if (metadata.pictures.isNotEmpty) {
        coverBytes = metadata.pictures.first.bytes;
      }

      return MetadataResult(
        title: metadata.title ?? nameWithoutExt,
        artist: metadata.artist ?? 'Unknown Artist',
        album: metadata.album ?? 'Unknown Album',
        durationMs: metadata.duration?.inMilliseconds ?? 0,
        coverArtBytes: coverBytes,
      );
    } catch (e) {
      // Fallback: use filename as title
      final file = File(filePath);
      final fileName = file.uri.pathSegments.last;
      final nameWithoutExt = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;

      return MetadataResult(
        title: nameWithoutExt,
        artist: 'Unknown Artist',
        album: 'Unknown Album',
        durationMs: 0,
      );
    }
  }
}
