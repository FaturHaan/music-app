import 'package:get_it/get_it.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/song_repository.dart';
import 'data/repositories/playlist_repository.dart';
import 'data/services/audio_player_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/metadata_service.dart';
import 'providers/player_provider.dart';
import 'providers/library_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/search_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/connectivity_provider.dart';

import 'data/sources/jamendo_source.dart';
import 'data/sources/itunes_source.dart';
import 'data/sources/lastfm_source.dart';
import 'data/sources/musicbrainz_source.dart';
import 'data/sources/source_aggregator.dart';
import 'data/sources/youtube_source.dart';
import 'data/services/enrichment_service.dart';
import 'providers/discovery_provider.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Database
  final dbHelper = DatabaseHelper();
  getIt.registerSingleton<DatabaseHelper>(dbHelper);

  // Sources
  final jamendoSource = JamendoSource();
  final itunesSource = ItunesSource();
  final lastFmSource = LastFmSource();
  final musicBrainzSource = MusicBrainzSource();
  final youtubeSource = YoutubeSource();
  getIt.registerSingleton<JamendoSource>(jamendoSource);
  getIt.registerSingleton<ItunesSource>(itunesSource);
  getIt.registerSingleton<LastFmSource>(lastFmSource);
  getIt.registerSingleton<MusicBrainzSource>(musicBrainzSource);
  getIt.registerSingleton<YoutubeSource>(youtubeSource);
  getIt.registerSingleton<SourceAggregator>(
    SourceAggregator([jamendoSource, itunesSource, youtubeSource]),
  );

  // Services
  final audioService = AudioPlayerService();
  await audioService.init();
  getIt.registerSingleton<AudioPlayerService>(audioService);
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<MetadataService>(MetadataService());
  getIt.registerSingleton<EnrichmentService>(
    EnrichmentService(
      getIt<StorageService>(),
      getIt<LastFmSource>(),
      getIt<MusicBrainzSource>(),
    ),
  );

  // Repositories
  getIt.registerSingleton<SongRepository>(SongRepository(dbHelper));
  getIt.registerSingleton<PlaylistRepository>(PlaylistRepository(dbHelper));

  // Providers
  getIt.registerSingleton<PlayerProvider>(
    PlayerProvider(getIt<AudioPlayerService>()),
  );
  getIt.registerSingleton<LibraryProvider>(
    LibraryProvider(
      getIt<SongRepository>(),
      getIt<StorageService>(),
      getIt<MetadataService>(),
      getIt<EnrichmentService>(),
    ),
  );
  getIt.registerSingleton<PlaylistProvider>(
    PlaylistProvider(getIt<PlaylistRepository>()),
  );
  getIt.registerSingleton<SearchProvider>(
    SearchProvider(
      getIt<SongRepository>(),
      getIt<SourceAggregator>(),
    ),
  );
  getIt.registerSingleton<DiscoveryProvider>(
    DiscoveryProvider(getIt<JamendoSource>()),
  );
  getIt.registerSingleton<SettingsProvider>(SettingsProvider());
  getIt.registerSingleton<ConnectivityProvider>(ConnectivityProvider());
}
