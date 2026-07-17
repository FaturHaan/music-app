import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Music App';
  static const String appVersion = '1.0.0';
  static const String dbName = 'music_app.db';
  static const int dbVersion = 2;

  // Directories
  static const String musicDir = 'music';
  static const String coversDir = 'covers';

  static String get lastfmApiKey {
    try {
      return dotenv.env['LASTFM_API_KEY'] ?? 'YOUR_LASTFM_API_KEY';
    } catch (_) {
      return 'YOUR_LASTFM_API_KEY';
    }
  }

  // API Base URLs
  static const String itunesBaseUrl = 'https://itunes.apple.com';
  static const String lastfmBaseUrl = 'https://ws.audioscrobbler.com/2.0';
  static const String musicbrainzBaseUrl = 'https://musicbrainz.org/ws/2';
  static const String coverArtArchiveBaseUrl = 'https://coverartarchive.org';

  // Stream cache duration
  static const Duration streamCacheDuration = Duration(hours: 5);

  // Animation durations
  static const Duration rotationDuration = Duration(seconds: 10);
  static const Duration waveDuration = Duration(seconds: 3);
  static const Duration slideTransitionDuration = Duration(milliseconds: 350);
  static const Duration staggeredAnimationDuration = Duration(milliseconds: 400);

  // Supported audio formats
  static const List<String> supportedFormats = [
    'mp3',
    'wav',
    'flac',
    'aac',
    'm4a',
    'ogg',
    'wma',
  ];

  // Music sources
  static const String sourceLocal = 'local';
  static const String sourceItunes = 'itunes';
  static const String sourceSoundcloud = 'soundcloud';

  // SoundCloud API
  static const String soundcloudBaseUrl = 'https://api.soundcloud.com';
}
