import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/data/models/speaking_topic.dart';
import 'package:yazich_ok/data/models/assessment_result.dart';
import 'package:yazich_ok/domain/repositories/network_repository.dart';
import 'package:yazich_ok/domain/managers/recorder_manager.dart';
import 'package:yazich_ok/presentation/speaking/cubit/speech_cubit.dart';
import 'package:yazich_ok/presentation/speaking/cubit/speech_state.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

class MockRecorderManager extends Mock implements RecorderManager {}

void main() {
  late MockNetworkRepository mockNetworkRepository;
  late MockRecorderManager mockRecorderManager;

  setUp(() {
    mockNetworkRepository = MockNetworkRepository();
    mockRecorderManager = MockRecorderManager();

    // Set up default stream for recorder duration
    when(() => mockRecorderManager.recordingDurationStream)
        .thenAnswer((_) => Stream.value(0));
    when(() => mockRecorderManager.isRecording).thenReturn(false);
  });

  final testTopics = [
    const SpeakingTopic(
      id: 'st-1',
      title: 'Describe your favorite vacation',
      description: 'Talk about a memorable trip you took',
      difficulty: 'intermediate',
      timeLimit: 120,
    ),
    const SpeakingTopic(
      id: 'st-2',
      title: 'Discuss your daily routine',
      description: 'Describe a typical day in your life',
      difficulty: 'beginner',
      timeLimit: 90,
    ),
  ];

  final testResult = AssessmentResult(
    id: 'ar-1',
    topicId: 'st-1',
    overallScore: 85,
    pronunciationScore: 80,
    fluencyScore: 88,
    accuracyScore: 87,
    feedback: 'Great job! Your pronunciation is clear.',
    timestamp: DateTime.now(),
  );

  group('SpeechCubit', () {
    group('loadTopics', () {
      blocTest<SpeechCubit, SpeechState>(
        'emits [SpeechTopicsLoading, SpeechTopicsLoaded] when successful',
        build: () {
          when(() => mockNetworkRepository.getSpeakingTopics())
              .thenAnswer((_) async => testTopics);
          return SpeechCubit(mockNetworkRepository, mockRecorderManager);
        },
        act: (cubit) => cubit.loadTopics(),
        expect: () => [
          const SpeechTopicsLoading(),
          SpeechTopicsLoaded(testTopics),
        ],
        verify: (_) {
          verify(() => mockNetworkRepository.getSpeakingTopics()).called(1);
        },
      );

      blocTest<SpeechCubit, SpeechState>(
        'emits [SpeechTopicsLoading, SpeechError] when fails',
        build: () {
          when(() => mockNetworkRepository.getSpeakingTopics())
              .thenThrow(Exception('Network error'));
          return SpeechCubit(mockNetworkRepository, mockRecorderManager);
        },
        act: (cubit) => cubit.loadTopics(),
        expect: () => [
          const SpeechTopicsLoading(),
          isA<SpeechError>()
              .having((e) => e.message, 'message', contains('Network error')),
        ],
      );
    });

    group('selectTopic', () {
      blocTest<SpeechCubit, SpeechState>(
        'emits SpeechRecordingIdle with selected topic',
        build: () => SpeechCubit(mockNetworkRepository, mockRecorderManager),
        act: (cubit) => cubit.selectTopic(testTopics.first),
        expect: () => [
          SpeechRecordingIdle(testTopics.first),
        ],
      );
    });

    group('startRecording', () {
      blocTest<SpeechCubit, SpeechState>(
        'emits SpeechRecording when recording starts',
        build: () {
          when(() => mockRecorderManager.startRecording())
              .thenAnswer((_) async {});
          when(() => mockRecorderManager.recordingDurationStream)
              .thenAnswer((_) => Stream.value(5));
          return SpeechCubit(mockNetworkRepository, mockRecorderManager);
        },
        seed: () => SpeechRecordingIdle(testTopics.first),
        act: (cubit) => cubit.startRecording(),
        expect: () => [
          SpeechRecording(testTopics.first, 0),
          SpeechRecording(testTopics.first, 5),
        ],
        verify: (_) {
          verify(() => mockRecorderManager.startRecording()).called(1);
        },
      );
    });

    group('stopRecording', () {
      blocTest<SpeechCubit, SpeechState>(
        'emits SpeechRecordingStopped with audio URL',
        build: () {
          when(() => mockRecorderManager.stopRecording())
              .thenAnswer((_) async => 'mock-audio-url');
          return SpeechCubit(mockNetworkRepository, mockRecorderManager);
        },
        seed: () => SpeechRecordingIdle(testTopics.first),
        act: (cubit) async {
          cubit.selectTopic(testTopics.first);
          await cubit.stopRecording();
        },
        skip: 1, // Skip the selectTopic emission
        expect: () => [
          isA<SpeechRecordingStopped>()
              .having((s) => s.audioUrl, 'audioUrl', 'mock-audio-url')
              .having((s) => s.topic, 'topic', testTopics.first),
        ],
        verify: (_) {
          verify(() => mockRecorderManager.stopRecording()).called(1);
        },
      );
    });

    group('submitRecording', () {
      blocTest<SpeechCubit, SpeechState>(
        'emits [SpeechAssessmentProcessing, SpeechAssessmentCompleted] when successful',
        build: () {
          when(() => mockRecorderManager.stopRecording())
              .thenAnswer((_) async => 'mock-audio-url');
          when(() => mockNetworkRepository.assessRecording(any(), any()))
              .thenAnswer((_) async => testResult);
          return SpeechCubit(mockNetworkRepository, mockRecorderManager);
        },
        seed: () => SpeechRecordingStopped(
          testTopics.first,
          'mock-audio-url',
          60,
        ),
        act: (cubit) => cubit.submitRecording(),
        expect: () => [
          SpeechAssessmentProcessing(testTopics.first),
          SpeechAssessmentCompleted(testTopics.first, testResult),
        ],
        verify: (_) {
          verify(() =>
                  mockNetworkRepository.assessRecording('mock-audio-url', 'st-1'))
              .called(1);
        },
      );
    });

    group('loadResultsHistory', () {
      blocTest<SpeechCubit, SpeechState>(
        'emits [SpeechResultsLoading, SpeechResultsLoaded] when successful',
        build: () {
          when(() => mockNetworkRepository.getAssessmentHistory())
              .thenAnswer((_) async => [testResult]);
          when(() => mockNetworkRepository.getSpeakingTopics())
              .thenAnswer((_) async => testTopics);
          return SpeechCubit(mockNetworkRepository, mockRecorderManager);
        },
        act: (cubit) => cubit.loadResultsHistory(),
        expect: () => [
          const SpeechResultsLoading(),
          isA<SpeechResultsLoaded>()
              .having((s) => s.results, 'results', [testResult])
              .having((s) => s.topicMap.length, 'topicMap.length', 2),
        ],
        verify: (_) {
          verify(() => mockNetworkRepository.getAssessmentHistory()).called(1);
          verify(() => mockNetworkRepository.getSpeakingTopics()).called(1);
        },
      );
    });

    group('backToTopics', () {
      blocTest<SpeechCubit, SpeechState>(
        'reloads topics and resets state',
        build: () {
          when(() => mockNetworkRepository.getSpeakingTopics())
              .thenAnswer((_) async => testTopics);
          return SpeechCubit(mockNetworkRepository, mockRecorderManager);
        },
        seed: () => SpeechRecordingIdle(testTopics.first),
        act: (cubit) => cubit.backToTopics(),
        expect: () => [
          const SpeechTopicsLoading(),
          SpeechTopicsLoaded(testTopics),
        ],
      );
    });
  });
}
