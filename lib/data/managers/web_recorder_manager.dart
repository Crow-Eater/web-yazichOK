import 'dart:async';
import '../../domain/managers/recorder_manager.dart';

/// Basic implementation of RecorderManager for web
/// Will be fully implemented in Phase 4 with Web Audio API
class WebRecorderManager implements RecorderManager {
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _timer;

  final _durationController = StreamController<int>.broadcast();

  @override
  Stream<int> get recordingDurationStream => _durationController.stream;

  @override
  bool get isRecording => _isRecording;

  @override
  Future<void> startRecording() async {
    _isRecording = true;
    _recordingDuration = 0;
    _durationController.add(0);

    // Simulate recording timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration++;
      _durationController.add(_recordingDuration);
    });

    // TODO: Implement actual audio recording in Phase 4
  }

  @override
  Future<String> stopRecording() async {
    _isRecording = false;
    _timer?.cancel();
    _timer = null;

    // TODO: Return actual audio blob/URL in Phase 4
    return 'mock-audio-blob-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> cancelRecording() async {
    _isRecording = false;
    _timer?.cancel();
    _timer = null;
    _recordingDuration = 0;
    _durationController.add(0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _durationController.close();
  }
}
