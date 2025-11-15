import 'package:equatable/equatable.dart';
import 'package:web_yazichok/data/models/speaking_topic.dart';
import 'package:web_yazichok/data/models/assessment_result.dart';

/// Base class for all speech states
abstract class SpeechState extends Equatable {
  const SpeechState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SpeechInitial extends SpeechState {
  const SpeechInitial();
}

/// Loading topics
class SpeechTopicsLoading extends SpeechState {
  const SpeechTopicsLoading();
}

/// Topics loaded successfully
class SpeechTopicsLoaded extends SpeechState {
  final List<SpeakingTopic> topics;

  const SpeechTopicsLoaded(this.topics);

  @override
  List<Object?> get props => [topics];
}

/// Ready to record (topic selected, not recording)
class SpeechRecordingIdle extends SpeechState {
  final SpeakingTopic topic;

  const SpeechRecordingIdle(this.topic);

  @override
  List<Object?> get props => [topic];
}

/// Currently recording
class SpeechRecording extends SpeechState {
  final SpeakingTopic topic;
  final int recordingDuration; // in seconds

  const SpeechRecording(this.topic, this.recordingDuration);

  @override
  List<Object?> get props => [topic, recordingDuration];

  SpeechRecording copyWith({
    SpeakingTopic? topic,
    int? recordingDuration,
  }) {
    return SpeechRecording(
      topic ?? this.topic,
      recordingDuration ?? this.recordingDuration,
    );
  }
}

/// Recording stopped, ready to submit or re-record
class SpeechRecordingStopped extends SpeechState {
  final SpeakingTopic topic;
  final String audioUrl; // URL or blob identifier
  final int recordingDuration;

  const SpeechRecordingStopped(
    this.topic,
    this.audioUrl,
    this.recordingDuration,
  );

  @override
  List<Object?> get props => [topic, audioUrl, recordingDuration];
}

/// Processing assessment
class SpeechAssessmentProcessing extends SpeechState {
  final SpeakingTopic topic;

  const SpeechAssessmentProcessing(this.topic);

  @override
  List<Object?> get props => [topic];
}

/// Assessment completed
class SpeechAssessmentCompleted extends SpeechState {
  final SpeakingTopic topic;
  final AssessmentResult result;

  const SpeechAssessmentCompleted(this.topic, this.result);

  @override
  List<Object?> get props => [topic, result];
}

/// Loading results history
class SpeechResultsLoading extends SpeechState {
  const SpeechResultsLoading();
}

/// Results history loaded
class SpeechResultsLoaded extends SpeechState {
  final List<AssessmentResult> results;
  final Map<String, SpeakingTopic> topicMap; // For displaying topic names

  const SpeechResultsLoaded(this.results, this.topicMap);

  @override
  List<Object?> get props => [results, topicMap];
}

/// Error state
class SpeechError extends SpeechState {
  final String message;

  const SpeechError(this.message);

  @override
  List<Object?> get props => [message];
}
