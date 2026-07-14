import 'package:http/http.dart' as http;
import '../models/song_model.dart';
import 'storage_service.dart';
import '../sources/lastfm_source.dart';
import '../sources/musicbrainz_source.dart';

class EnrichmentService {
  final StorageService _storageService;
  final LastFmSource _lastFmSource;
  final MusicBrainzSource _musicBrainzSource;

  EnrichmentService(
    this._storageService,
    this._lastFmSource,
    this._musicBrainzSource,
  );

  /// Enrich a local song with metadata and cover art from online sources
  Future<SongModel> enrichLocalSong(SongModel song) async {
    if (song.title == 'Unknown Title' || song.artist == 'Unknown Artist') {
      return song;
    }

    String? coverArtUrl;
    String? enrichedAlbum = song.album;

    // 1. Try Last.fm first (usually faster and has good coverage)
    try {
      final lastFmInfo = await _lastFmSource.getTrackInfo(song.artist, song.title);
      if (lastFmInfo != null) {
        if (enrichedAlbum == 'Unknown Album' && lastFmInfo['album'] != null) {
          enrichedAlbum = lastFmInfo['album']['title'];
        }
        coverArtUrl = _lastFmSource.extractCoverArtUrl(lastFmInfo);
      }
    } catch (e) {
      // Ignore
    }

    // 2. If no cover art, try MusicBrainz + Cover Art Archive
    if (coverArtUrl == null || coverArtUrl.isEmpty) {
      try {
        final mbid = await _musicBrainzSource.getReleaseMbid(song.artist, song.title);
        if (mbid != null) {
          coverArtUrl = await _musicBrainzSource.getCoverArtUrl(mbid);
        }
      } catch (e) {
        // Ignore
      }
    }

    // 3. Download and save cover art if found
    String? localCoverPath = song.coverArtPath;
    if (coverArtUrl != null && coverArtUrl.isNotEmpty && localCoverPath == null) {
      try {
        final response = await http.get(Uri.parse(coverArtUrl));
        if (response.statusCode == 200) {
          localCoverPath = await _storageService.saveCoverArt(response.bodyBytes);
        }
      } catch (e) {
        // Ignore download errors
      }
    }

    // Return enriched song
    return song.copyWith(
      album: enrichedAlbum,
      coverArtPath: localCoverPath,
      thumbnailUrl: coverArtUrl,
    );
  }
}
