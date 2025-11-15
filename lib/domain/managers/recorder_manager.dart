/// Interface for audio recording operations
/// Implementation uses Web Audio API for web
abstract class RecorderManager {
  /// Start recording audio
  Future<void> startRecording();

  /// Stop recording and return audio blob/URL
  Future<String> stopRecording();

  /// Cancel recording without saving
  Future<void> cancelRecording();

  /// Check if currently recording
  bool get isRecording;

  /// Stream of recording duration in seconds
  Stream<int> get recordingDurationStream;

  /// Dispose resources
  void dispose();
}
