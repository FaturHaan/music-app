import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../data/models/song_model.dart';
import '../data/services/audio_player_service.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;

  PlayerProvider(this._audioService) {
    _listenToChanges();
  }

  SongModel? _currentSong;
  List<SongModel> _queue = [];
  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  LoopMode _loopMode = LoopMode.off;
  bool _shuffleEnabled = false;
  String? _error;

  // Sleep timer
  Timer? _sleepTimer;
  DateTime? _sleepTimerEndTime;

  SongModel? get currentSong => _currentSong;
  List<SongModel> get queue => _queue;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get position => _position;
  Duration get duration => _duration;
  LoopMode get loopMode => _loopMode;
  bool get shuffleEnabled => _shuffleEnabled;
  bool get hasCurrentSong => _currentSong != null;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _listenToChanges() {
    _audioService.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _audioService.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _audioService.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isBuffering = state.processingState == ProcessingState.buffering || 
                     state.processingState == ProcessingState.loading;

      // Auto play next or handle completion
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
      }

      notifyListeners();
    });

    _audioService.currentIndexStream.listen((index) {
      if (index != null && index < _queue.length) {
        _currentSong = _queue[index];
        notifyListeners();
      }
    });

    _audioService.loopModeStream.listen((mode) {
      _loopMode = mode;
      notifyListeners();
    });

    _audioService.shuffleModeEnabledStream.listen((enabled) {
      _shuffleEnabled = enabled;
      notifyListeners();
    });
  }

  Future<void> playSong(SongModel song, List<SongModel> queue) async {
    try {
      _error = null;
      _queue = List.from(queue);
      final index = _queue.indexWhere((s) => s.id == song.id);
      _currentSong = song;
      notifyListeners();

      await _audioService.setQueue(queue, startIndex: index >= 0 ? index : 0);
      await _audioService.play();
    } catch (e) {
      _error = 'Failed to play song: $e';
      notifyListeners();
    }
  }

  Future<void> play() async {
    try {
      await _audioService.play();
    } catch (e) {
      _error = 'Playback error: $e';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _audioService.pause();
    } catch (e) {
      _error = 'Pause error: $e';
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    try {
      await _audioService.seekToNext();
    } catch (e) {
      _error = 'Skip error: $e';
      notifyListeners();
    }
  }

  Future<void> previous() async {
    try {
      await _audioService.seekToPrevious();
    } catch (e) {
      _error = 'Skip error: $e';
      notifyListeners();
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioService.seek(position);
    } catch (e) {
      _error = 'Seek error: $e';
      notifyListeners();
    }
  }

  Future<void> toggleLoopMode() async {
    LoopMode nextMode;
    switch (_loopMode) {
      case LoopMode.off:
        nextMode = LoopMode.all;
        break;
      case LoopMode.all:
        nextMode = LoopMode.one;
        break;
      case LoopMode.one:
        nextMode = LoopMode.off;
        break;
    }
    await _audioService.setLoopMode(nextMode);
  }

  Future<void> toggleShuffle() async {
    await _audioService.setShuffleModeEnabled(!_shuffleEnabled);
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  // --- Sleep Timer ---

  DateTime? get sleepTimerEndTime => _sleepTimerEndTime;
  bool get isSleepTimerActive => _sleepTimer != null && _sleepTimer!.isActive;

  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimerEndTime = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, () {
      pause();
      cancelSleepTimer();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerEndTime = null;
    notifyListeners();
  }
}
