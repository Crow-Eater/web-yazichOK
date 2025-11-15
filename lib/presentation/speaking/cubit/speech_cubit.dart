import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yazich_ok/domain/repositories/network_repository.dart';
import 'package:yazich_ok/domain/managers/recorder_manager.dart';
import 'package:yazich_ok/data/models/speaking_topic.dart';
import 'package:yazich_ok/presentation/speaking/cubit/speech_state.dart';

/// Cubit for managing speaking practice state
class SpeechCubit extends Cubit<SpeechState> {
  final NetworkRepository _networkRepository;
  final RecorderManager _recorderManager;

  StreamSubscription<int>? _durationSubscription;
  SpeakingTopic? _currentTopic;
  String? _currentAudioUrl;
  int _currentDuration = 0;

  SpeechCubit(this._networkRepository, this._recorderManager)
      : super(const SpeechInitial());

  /// Load all speaking topics
  Future<void> loadTopics() async {
    try {
      print('DEBUG: SpeechCubit.loadTopics() called');
      emit(const SpeechTopicsLoading());
      print('DEBUG: Emitted SpeechTopicsLoading state');
      final topics = await _networkRepository.getSpeakingTopics();
      print('DEBUG: Got ${topics.length} topics from repository');
      emit(SpeechTopicsLoaded(topics));
      print('DEBUG: Emitted SpeechTopicsLoaded state with ${topics.length} topics');
    } catch (e) {
      print('DEBUG: Error loading topics: $e');
      emit(SpeechError('Failed to load topics: ${e.toString()}'));
    }
  }

  /// Select a topic and navigate to recording screen
  void selectTopic(SpeakingTopic topic) {
    _currentTopic = topic;
    emit(SpeechRecordingIdle(topic));
  }

  /// Start recording
  Future<void> startRecording() async {
    if (_currentTopic == null) return;

    try {
      await _recorderManager.startRecording();
      _currentDuration = 0;

      // Listen to recording duration stream
      _durationSubscription =
          _recorderManager.recordingDurationStream.listen((duration) {
        _currentDuration = duration;
        emit(SpeechRecording(_currentTopic!, duration));

        // Auto-stop when reaching time limit
        if (duration >= _currentTopic!.timeLimit) {
          stopRecording();
        }
      });

      emit(SpeechRecording(_currentTopic!, 0));
    } catch (e) {
      emit(SpeechError('Failed to start recording: ${e.toString()}'));
    }
  }

  /// Stop recording
  Future<void> stopRecording() async {
    if (_currentTopic == null) return;

    try {
      await _durationSubscription?.cancel();
      _durationSubscription = null;

      final audioUrl = await _recorderManager.stopRecording();
      _currentAudioUrl = audioUrl;

      emit(SpeechRecordingStopped(
        _currentTopic!,
        audioUrl,
        _currentDuration,
      ));
    } catch (e) {
      emit(SpeechError('Failed to stop recording: ${e.toString()}'));
    }
  }

  /// Cancel recording and return to idle
  Future<void> cancelRecording() async {
    if (_currentTopic == null) return;

    try {
      await _durationSubscription?.cancel();
      _durationSubscription = null;
      await _recorderManager.cancelRecording();
      emit(SpeechRecordingIdle(_currentTopic!));
    } catch (e) {
      emit(SpeechError('Failed to cancel recording: ${e.toString()}'));
    }
  }

  /// Re-record (reset to idle state)
  Future<void> reRecord() async {
    if (_currentTopic == null) return;
    _currentAudioUrl = null;
    _currentDuration = 0;
    emit(SpeechRecordingIdle(_currentTopic!));
  }

  /// Submit recording for assessment
  Future<void> submitRecording() async {
    if (_currentTopic == null || _currentAudioUrl == null) return;

    try {
      emit(SpeechAssessmentProcessing(_currentTopic!));

      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));

      final result = await _networkRepository.assessRecording(
        _currentAudioUrl!,
        _currentTopic!.id,
      );

      emit(SpeechAssessmentCompleted(_currentTopic!, result));
    } catch (e) {
      emit(SpeechError('Failed to assess recording: ${e.toString()}'));
    }
  }

  /// Load assessment results history
  Future<void> loadResultsHistory() async {
    try {
      emit(const SpeechResultsLoading());
      final results = await _networkRepository.getAssessmentHistory();
      final topics = await _networkRepository.getSpeakingTopics();

      // Create a map of topic IDs to topics for easy lookup
      final topicMap = {for (var topic in topics) topic.id: topic};

      emit(SpeechResultsLoaded(results, topicMap));
    } catch (e) {
      emit(SpeechError('Failed to load results: ${e.toString()}'));
    }
  }

  /// Reset to topics list
  void backToTopics() {
    _currentTopic = null;
    _currentAudioUrl = null;
    _currentDuration = 0;
    loadTopics();
  }

  @override
  Future<void> close() async {
    await _durationSubscription?.cancel();
    return super.close();
  }
}
