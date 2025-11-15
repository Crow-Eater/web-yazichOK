import 'dart:async';
import '../../domain/managers/audio_manager.dart';
import '../models/audio_record.dart';

/// Basic implementation of AudioManager for web
/// Will be fully implemented in Phase 3 with just_audio package
class LocalAudioManager implements AudioManager {
  AudioRecord? _currentRecord;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration? _duration;

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _playbackStateController = StreamController<bool>.broadcast();

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Stream<bool> get playbackStateStream => _playbackStateController.stream;

  @override
  Duration? get position => _position;

  @override
  Duration? get duration => _duration;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> load(AudioRecord record) async {
    _currentRecord = record;
    // Parse duration string (e.g., "02:10" -> Duration)
    final parts = record.duration.split(':');
    if (parts.length == 2) {
      final minutes = int.parse(parts[0]);
      final seconds = int.parse(parts[1]);
      _duration = Duration(minutes: minutes, seconds: seconds);
      _durationController.add(_duration);
    }
    _position = Duration.zero;
    _positionController.add(_position);
  }

  @override
  Future<void> play() async {
    if (_currentRecord == null) return;
    _isPlaying = true;
    _playbackStateController.add(true);
    // TODO: Implement actual audio playback in Phase 3
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    _playbackStateController.add(false);
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    _position = Duration.zero;
    _positionController.add(_position);
    _playbackStateController.add(false);
  }

  @override
  Future<void> seek(Duration position) async {
    _position = position;
    _positionController.add(_position);
  }

  @override
  Future<void> seekForward(int seconds) async {
    final newPosition = _position + Duration(seconds: seconds);
    if (_duration != null && newPosition <= _duration!) {
      await seek(newPosition);
    } else if (_duration != null) {
      await seek(_duration!);
    }
  }

  @override
  Future<void> seekBackward(int seconds) async {
    final newPosition = _position - Duration(seconds: seconds);
    if (newPosition >= Duration.zero) {
      await seek(newPosition);
    } else {
      await seek(Duration.zero);
    }
  }

  @override
  void dispose() {
    _positionController.close();
    _durationController.close();
    _playbackStateController.close();
  }
}
