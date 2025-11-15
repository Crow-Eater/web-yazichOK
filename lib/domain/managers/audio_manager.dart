import '../../data/models/audio_record.dart';

/// Interface for audio playback operations
/// Implementation uses just_audio for web
abstract class AudioManager {
  /// Load an audio record
  Future<void> load(AudioRecord record);

  /// Play the loaded audio
  Future<void> play();

  /// Pause playback
  Future<void> pause();

  /// Stop playback
  Future<void> stop();

  /// Seek to a specific position
  Future<void> seek(Duration position);

  /// Seek forward by specified seconds
  Future<void> seekForward(int seconds);

  /// Seek backward by specified seconds
  Future<void> seekBackward(int seconds);

  /// Stream of current playback position
  Stream<Duration> get positionStream;

  /// Stream of total duration
  Stream<Duration?> get durationStream;

  /// Stream of playback state
  Stream<bool> get playbackStateStream;

  /// Get current position
  Duration? get position;

  /// Get total duration
  Duration? get duration;

  /// Check if currently playing
  bool get isPlaying;

  /// Dispose resources
  void dispose();
}
