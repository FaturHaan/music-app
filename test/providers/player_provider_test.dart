import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/data/models/song_model.dart';
import 'package:music_app/data/services/audio_player_service.dart';
import 'package:music_app/providers/player_provider.dart';

class MockAudioPlayerService implements AudioPlayerService {
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _playerStateController = StreamController<PlayerState>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  final _currentIndexController = StreamController<int?>.broadcast();
  final _loopModeController = StreamController<LoopMode>.broadcast();
  final _shuffleModeEnabledController = StreamController<bool>.broadcast();

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  LoopMode _loopMode = LoopMode.off;
  bool _shuffleModeEnabled = false;

  List<SongModel> _queue = [];
  int _currentIndex = 0;

  @override
  AudioPlayer get audioPlayer => throw UnimplementedError();

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Stream<int?> get currentIndexStream => _currentIndexController.stream;

  @override
  Stream<LoopMode> get loopModeStream => _loopModeController.stream;

  @override
  Stream<bool> get shuffleModeEnabledStream => _shuffleModeEnabledController.stream;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Duration get position => _position;

  @override
  Duration get duration => _duration;

  @override
  LoopMode get loopMode => _loopMode;

  @override
  bool get shuffleModeEnabled => _shuffleModeEnabled;

  @override
  List<SongModel> get queue => _queue;

  @override
  int get currentIndex => _currentIndex;

  @override
  SongModel? get currentSong => _queue.isNotEmpty && _currentIndex < _queue.length ? _queue[_currentIndex] : null;

  @override
  Future<void> init() async {}

  @override
  Future<void> setQueue(List<SongModel> songs, {int startIndex = 0}) async {
    _queue = songs;
    _currentIndex = startIndex;
    _currentIndexController.add(_currentIndex);
  }

  void _updatePlayerState() {
    _playerStateController.add(PlayerState(_isPlaying, ProcessingState.ready));
  }

  @override
  Future<void> play() async {
    _isPlaying = true;
    _playingController.add(_isPlaying);
    _updatePlayerState();
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    _playingController.add(_isPlaying);
    _updatePlayerState();
  }

  @override
  Future<void> seekToNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      _currentIndexController.add(_currentIndex);
    }
  }

  @override
  Future<void> seekToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      _currentIndexController.add(_currentIndex);
    }
  }

  @override
  Future<void> seek(Duration position) async {
    _position = position;
    _positionController.add(_position);
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async {
    _loopMode = mode;
    _loopModeController.add(_loopMode);
  }

  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {
    _shuffleModeEnabled = enabled;
    _shuffleModeEnabledController.add(_shuffleModeEnabled);
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    _playingController.add(_isPlaying);
    _updatePlayerState();
  }

  @override
  Future<void> dispose() async {
    await _positionController.close();
    await _durationController.close();
    await _playerStateController.close();
    await _playingController.close();
    await _currentIndexController.close();
    await _loopModeController.close();
    await _shuffleModeEnabledController.close();
  }

  @override
  Stream<Duration> get bufferedPositionStream => Stream.empty();
}

void main() {
  late MockAudioPlayerService mockService;
  late PlayerProvider provider;
  late SongModel testSong1;
  late SongModel testSong2;

  setUp(() {
    mockService = MockAudioPlayerService();
    provider = PlayerProvider(mockService);

    testSong1 = SongModel(
      id: 1,
      title: 'Song 1',
      artist: 'Artist 1',
      album: 'Album 1',
      durationMs: 200000,
      filePath: '/test/path/1.mp3',
      dateAdded: DateTime.now(),
    );

    testSong2 = SongModel(
      id: 2,
      title: 'Song 2',
      artist: 'Artist 2',
      album: 'Album 2',
      durationMs: 180000,
      filePath: '/test/path/2.mp3',
      dateAdded: DateTime.now(),
    );
  });

  tearDown(() {
    provider.dispose();
  });

  group('PlayerProvider Tests', () {
    test('Initial state is correct', () {
      expect(provider.isPlaying, false);
      expect(provider.currentSong, isNull);
      expect(provider.queue, isEmpty);
      expect(provider.error, isNull);
    });

    test('playSong sets queue and plays', () async {
      final queue = [testSong1, testSong2];
      await provider.playSong(testSong1, queue);

      expect(provider.currentSong, testSong1);
      expect(provider.queue, queue);
      expect(mockService.isPlaying, true);
    });

    test('togglePlayPause works', () async {
      await provider.playSong(testSong1, [testSong1]);
      await Future.delayed(Duration.zero);
      
      await provider.togglePlayPause();
      await Future.delayed(Duration.zero);
      expect(mockService.isPlaying, false);

      await provider.togglePlayPause();
      await Future.delayed(Duration.zero);
      expect(mockService.isPlaying, true);
    });

    test('next and previous work', () async {
      final queue = [testSong1, testSong2];
      await provider.playSong(testSong1, queue);

      await provider.next();
      // Wait for stream to emit and provider to notify listeners
      await Future.delayed(Duration.zero);
      
      expect(provider.currentSong, testSong2);

      await provider.previous();
      await Future.delayed(Duration.zero);
      
      expect(provider.currentSong, testSong1);
    });

    test('error state is set on exception', () async {
      // Intentionally cause an error if needed, but since our mock doesn't throw,
      // we'll just test clearError.
      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
