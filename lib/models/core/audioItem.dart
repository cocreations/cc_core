import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

enum AudioState {
  noAudio,
  notStarted,
  playing,
  paused,
  finished,
}

/// Handles all of the audio data.
///
/// It's a bit of a stupid name, but I can't be arsed spending 20 minutes to come up with a good one.
class AudioItem {
  AudioItem({
    @required this.duration,
    @required this.audioFile,
    this.initialSeek = Duration.zero,
    this.initialState = AudioState.notStarted,
  }) {
    _state = initialState;
    _seek = initialSeek;
  }

  final Duration duration;
  final File audioFile;
  final AudioState initialState;
  final Duration initialSeek;
  Duration _seek;
  AudioState _state;
  AudioPlayer _audioPlayer;
  bool _loop = false;

  StreamSubscription<Duration> _playerSeekSubscription;
  StreamSubscription<PlayerState> _playerStateSubscription;

  bool _seekStreamHasListeners = false;
  bool _stateStreamHasListeners = false;
  StreamController<Duration> _seekStreamController;
  StreamController<AudioState> _stateStreamController;

  void dispose() {
    if (_playerSeekSubscription != null) _playerSeekSubscription.cancel();
    if (_playerStateSubscription != null) _playerStateSubscription.cancel();
    if (_seekStreamController != null) _seekStreamController.close();
    if (_stateStreamController != null) _stateStreamController.close();
    if (_audioPlayer != null) _audioPlayer.dispose();
  }

  String toString() {
    return "{file: $audioFile, state: $_state, duration: $duration, seek: $_seek}";
  }

  Duration get seek => _seek;
  AudioState get state => _state;
  bool get loop => loop;

  /// Try not to use this wherever possible
  AudioPlayer get audioPlayer {
    if (_audioPlayer == null) {
      return _createAttachedPlayer();
    }
    return _audioPlayer;
  }

  /// Broadcasts a new Duration every time a this gets a new duration.
  ///
  /// This usually happens every ~200ms when the audio is playing
  Stream<Duration> get onSeekChange {
    if (_seekStreamController == null) {
      _seekStreamController = StreamController<Duration>.broadcast(
        onListen: () {
          _seekStreamHasListeners = true;
        },
        onCancel: () {
          _seekStreamHasListeners = false;
        },
      );
    }

    return _seekStreamController.stream;
  }

  Stream<AudioState> get onStateChange {
    if (_stateStreamController == null) {
      _stateStreamController = StreamController<AudioState>.broadcast(
        onListen: () {
          _stateStreamHasListeners = true;
        },
        onCancel: () {
          _stateStreamHasListeners = false;
        },
      );
    }
    return _stateStreamController.stream;
  }

  set loop(bool newLoop) {
    if (_state == AudioState.noAudio) return;
    _loop = newLoop;
    if (_audioPlayer != null) {
      if (_loop) {
        audioPlayer.setReleaseMode(ReleaseMode.LOOP);
      } else {
        audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
      }
    }
  }

  /// sets the seek and runs .seek on the audio player if necessary
  set seek(Duration newSeek) {
    _seek = newSeek;
    if (_audioPlayer != null) {
      _audioPlayer.seek(newSeek);
    }
    if (_seekStreamHasListeners) {
      _seekStreamController.add(newSeek);
    }
  }

  /// resets the seek and audio state
  void reset() {
    _state = AudioState.notStarted;
    seek = Duration.zero;
    if (_stateStreamHasListeners) _stateStreamController.add(_state);
  }

  /// Plays the audio at the seek position
  void play() {
    if (_state == AudioState.noAudio) return;

    if (_state == AudioState.finished) _seek = Duration.zero;

    _state = AudioState.playing;
    audioPlayer.play(audioFile.path, isLocal: true, position: _seek);
    if (_loop) {
      audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    } else {
      audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
    }
    if (_stateStreamHasListeners) _stateStreamController.add(_state);
  }

  /// Resumes the audio if it is able to be resumed, otherwise, it plays from the seek position.
  ///
  /// This is mostly for HotspotAudioItem, but it does a few more checks and is otherwise better than
  /// ```dart
  ///   audioPlayer.resume()
  /// ```
  void resume() {
    if (_state == AudioState.noAudio) return;
    _state = AudioState.playing;

    if (_audioPlayer != null && _audioPlayer.state == PlayerState.PAUSED) {
      _audioPlayer.resume();
    } else {
      audioPlayer.play(audioFile.path, isLocal: true, position: _seek);
    }

    if (_loop) {
      audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    } else {
      audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
    }

    if (_stateStreamHasListeners) _stateStreamController.add(_state);
  }

  /// Pauses the audio and saves the seek position
  void pause() {
    if (_state == AudioState.noAudio) return;
    if (_audioPlayer != null) {
      audioPlayer.pause().then((value) {
        _state = AudioState.paused;
        if (_stateStreamHasListeners) _stateStreamController.add(_state);
      });
    }
  }

  /// Destroys the current audio player to free up resources
  void destroyAudioPlayer() async {
    if (_state == AudioState.playing) await _audioPlayer.stop();

    _stateStreamHasListeners = false;
    _seekStreamHasListeners = false;

    if (_playerSeekSubscription != null) _playerSeekSubscription.cancel();
    if (_playerStateSubscription != null) _playerStateSubscription.cancel();
    if (_audioPlayer != null) _audioPlayer.dispose();
    _audioPlayer = null;

    if (_state != AudioState.noAudio) {
      if (_seek.inSeconds >= duration.inSeconds && !_loop)
        _state = AudioState.finished;
      else if (_seek.inSeconds < 1)
        _state = AudioState.notStarted;
      else
        _state = AudioState.paused;

      if (_stateStreamHasListeners) _stateStreamController.add(_state);
    }
  }

  /// Creates an audio player and attaches the streams to it
  AudioPlayer _createAttachedPlayer() {
    _audioPlayer = AudioPlayer();

    _playerSeekSubscription = _audioPlayer.onAudioPositionChanged.listen((event) {
      _seek = event;
      if (_seekStreamHasListeners) _seekStreamController.add(event);
    });

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((event) {
      switch (event) {
        case PlayerState.PAUSED:
          _state = AudioState.paused;
          break;

        case PlayerState.PLAYING:
          _state = AudioState.playing;
          break;

        case PlayerState.STOPPED:
          _state = AudioState.paused;
          break;

        case PlayerState.COMPLETED:
          _state = AudioState.finished;
          break;
      }
      if (_stateStreamHasListeners) _stateStreamController.add(_state);
    });

    _audioPlayer.seek(_seek);

    return _audioPlayer;
  }

  static Future<AudioItem> buildFromFile(File audioFile, [Duration seek]) async {
    AudioState _state = AudioState.notStarted;

    Duration _seek = Duration.zero;
    if (seek != null) _seek = seek;

    if (_seek.inMilliseconds > 0) {
      _state = AudioState.paused;
    }

    Duration _duration = Duration.zero;

    if (audioFile != null) {
      final AudioPlayer _durationPlayer = AudioPlayer();

      Future<Duration> _futureDuration = _durationPlayer.onDurationChanged.first.then((value) async {
        await _durationPlayer.stop();
        _durationPlayer.dispose();

        return value;
      });

      _durationPlayer.play(audioFile.path, isLocal: true, volume: 0.0);

      _duration = await _futureDuration;
    }

    if (_seek.inSeconds >= _duration.inSeconds) _state = AudioState.finished;

    if (audioFile == null) _state = AudioState.noAudio;

    return AudioItem(
      duration: _duration,
      audioFile: audioFile,
      initialSeek: _seek,
      initialState: _state,
    );
  }
}
