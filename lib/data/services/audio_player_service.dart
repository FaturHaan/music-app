import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

class AudioPlayerService {
  late AudioHandler _audioHandler;
  late AudioPlayer _audioPlayer;
  ConcatenatingAudioSource? _playlist;

  List<SongModel> _queue = [];
  int _currentIndex = 0;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<SongModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong =>
      _queue.isNotEmpty && _currentIndex < _queue.length
          ? _queue[_currentIndex]
          : null;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;
  Stream<LoopMode> get loopModeStream => _audioPlayer.loopModeStream;
  Stream<bool> get shuffleModeEnabledStream =>
      _audioPlayer.shuffleModeEnabledStream;

  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;
  LoopMode get loopMode => _audioPlayer.loopMode;
  bool get shuffleModeEnabled => _audioPlayer.shuffleModeEnabled;

  Future<void> init() async {
    _audioPlayer = AudioPlayer();

    _audioHandler = await AudioService.init(
      builder: () => _MusicAudioHandler(_audioPlayer),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.musicapp.music_app.channel.audio',
        androidNotificationChannelName: 'Music App',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    );

    // Listen for index changes
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index < _queue.length) {
        _currentIndex = index;
        _updateMediaItem();
      }
    });
  }

  Future<void> setQueue(List<SongModel> songs, {int startIndex = 0}) async {
    _queue = List.from(songs);
    _currentIndex = startIndex;

    final sources = songs.map((song) {
      final audioSource = song.streamUrl != null && song.streamUrl!.isNotEmpty
          ? AudioSource.uri(
              Uri.parse(song.streamUrl!),
              tag: MediaItem(
                id: song.id?.toString() ?? song.sourceId ?? song.title,
                title: song.title,
                artist: song.artist,
                album: song.album,
                duration: Duration(milliseconds: song.durationMs),
                artUri: song.bestCoverArt != null
                    ? (song.bestCoverArt!.startsWith('http')
                        ? Uri.parse(song.bestCoverArt!)
                        : Uri.file(song.bestCoverArt!))
                    : null,
              ),
            )
          : AudioSource.file(
              song.filePath,
              tag: MediaItem(
                id: song.id?.toString() ?? song.filePath,
                title: song.title,
                artist: song.artist,
                album: song.album,
                duration: Duration(milliseconds: song.durationMs),
                artUri: song.coverArtPath != null
                    ? Uri.file(song.coverArtPath!)
                    : null,
              ),
            );
      return audioSource;
    }).toList();

    _playlist = ConcatenatingAudioSource(children: sources);
    await _audioPlayer.setAudioSource(
      _playlist!,
      initialIndex: startIndex,
    );

    _updateMediaItem();
  }

  Stream<Duration> get bufferedPositionStream => _audioPlayer.bufferedPositionStream;

  void _updateMediaItem() {
    if (currentSong != null) {
      (_audioHandler as _MusicAudioHandler).setMediaItem(MediaItem(
        id: currentSong!.id?.toString() ?? currentSong!.sourceId ?? currentSong!.title,
        title: currentSong!.title,
        artist: currentSong!.artist,
        album: currentSong!.album,
        duration: Duration(milliseconds: currentSong!.durationMs),
        artUri: currentSong!.bestCoverArt != null
            ? (currentSong!.bestCoverArt!.startsWith('http')
                ? Uri.parse(currentSong!.bestCoverArt!)
                : Uri.file(currentSong!.bestCoverArt!))
            : null,
      ));
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> seekToNext() async {
    await _audioPlayer.seekToNext();
  }

  Future<void> seekToPrevious() async {
    await _audioPlayer.seekToPrevious();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _audioPlayer.setLoopMode(mode);
  }

  Future<void> setShuffleModeEnabled(bool enabled) async {
    await _audioPlayer.setShuffleModeEnabled(enabled);
    if (enabled) {
      await _audioPlayer.shuffle();
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

class _MusicAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  _MusicAudioHandler(this._player) {
    // Broadcast playback state changes
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  void setMediaItem(MediaItem item) {
    mediaItem.add(item);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }
}
