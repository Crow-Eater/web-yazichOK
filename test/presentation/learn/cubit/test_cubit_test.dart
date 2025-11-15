import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_yazichok/data/models/question.dart';
import 'package:web_yazichok/domain/repositories/network_repository.dart';
import 'package:web_yazichok/presentation/learn/cubit/test_cubit.dart';
import 'package:web_yazichok/presentation/learn/cubit/test_state.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  group('TestCubit', () {
    late MockNetworkRepository mockNetworkRepository;
    late TestCubit cubit;

    setUp(() {
      mockNetworkRepository = MockNetworkRepository();
      cubit = TestCubit(mockNetworkRepository);
    });

    tearDown(() {
      cubit.close();
    });

    final testQuestions = [
      Question(
        id: 'q-1',
        text: 'Choose the correct article',
        options: ['A', 'An', 'The', 'No article'],
        correctOptionIndex: 1,
        explanation: 'Use "An" before vowel sounds',
      ),
      Question(
        id: 'q-2',
        text: 'Select the right tense',
        options: ['go', 'goes', 'went', 'gone'],
        correctOptionIndex: 2,
      ),
    ];

    test('initial state is TestInitial', () {
      expect(cubit.state, const TestInitial());
    });

    group('loadTopic', () {
      blocTest<TestCubit, TestState>(
        'emits [Loading, QuestionLoaded] when successful',
        build: () {
          when(() => mockNetworkRepository.getQuestions('t-1'))
              .thenAnswer((_) async => testQuestions);
          return cubit;
        },
        act: (cubit) => cubit.loadTopic('t-1'),
        expect: () => [
          const TestLoading(),
          TestQuestionLoaded(
            question: testQuestions[0],
            currentQuestionIndex: 0,
            totalQuestions: 2,
            selectedOptionIndex: null,
            correctAnswersCount: 0,
          ),
        ],
      );

      blocTest<TestCubit, TestState>(
        'emits Error when no questions available',
        build: () {
          when(() => mockNetworkRepository.getQuestions('t-1'))
              .thenAnswer((_) async => []);
          return cubit;
        },
        act: (cubit) => cubit.loadTopic('t-1'),
        expect: () => [
          const TestLoading(),
          const TestError('No questions available for this topic'),
        ],
      );
    });

    group('selectOption', () {
      blocTest<TestCubit, TestState>(
        'updates selected option',
        build: () {
          when(() => mockNetworkRepository.getQuestions('t-1'))
              .thenAnswer((_) async => testQuestions);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadTopic('t-1');
          cubit.selectOption(1);
        },
        skip: 2, // Skip loading and initial question
        expect: () => [
          TestQuestionLoaded(
            question: testQuestions[0],
            currentQuestionIndex: 0,
            totalQuestions: 2,
            selectedOptionIndex: 1,
            correctAnswersCount: 0,
          ),
        ],
      );
    });

    group('checkAnswer', () {
      blocTest<TestCubit, TestState>(
        'shows result for correct answer',
        build: () {
          when(() => mockNetworkRepository.getQuestions('t-1'))
              .thenAnswer((_) async => testQuestions);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadTopic('t-1');
          cubit.selectOption(1); // Correct answer
          cubit.checkAnswer();
        },
        skip: 3, // Skip loading, question, and select option
        expect: () => [
          TestResultShown(
            question: testQuestions[0],
            selectedOptionIndex: 1,
            isCorrect: true,
            explanation: 'Use "An" before vowel sounds',
            currentQuestionIndex: 0,
            totalQuestions: 2,
            correctAnswersCount: 1,
          ),
        ],
      );

      blocTest<TestCubit, TestState>(
        'shows result for incorrect answer',
        build: () {
          when(() => mockNetworkRepository.getQuestions('t-1'))
              .thenAnswer((_) async => testQuestions);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadTopic('t-1');
          cubit.selectOption(0); // Incorrect answer
          cubit.checkAnswer();
        },
        skip: 3,
        expect: () => [
          TestResultShown(
            question: testQuestions[0],
            selectedOptionIndex: 0,
            isCorrect: false,
            explanation: 'Use "An" before vowel sounds',
            currentQuestionIndex: 0,
            totalQuestions: 2,
            correctAnswersCount: 0,
          ),
        ],
      );
    });

    group('continueToNext', () {
      blocTest<TestCubit, TestState>(
        'moves to next question',
        build: () {
          when(() => mockNetworkRepository.getQuestions('t-1'))
              .thenAnswer((_) async => testQuestions);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadTopic('t-1');
          cubit.selectOption(1);
          cubit.checkAnswer();
          cubit.continueToNext();
        },
        skip: 4,
        expect: () => [
          TestQuestionLoaded(
            question: testQuestions[1],
            currentQuestionIndex: 1,
            totalQuestions: 2,
            selectedOptionIndex: null,
            correctAnswersCount: 1,
          ),
        ],
      );

      blocTest<TestCubit, TestState>(
        'shows completion when all questions answered',
        build: () {
          when(() => mockNetworkRepository.getQuestions('t-1'))
              .thenAnswer((_) async => [testQuestions[0]]);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadTopic('t-1');
          cubit.selectOption(1);
          cubit.checkAnswer();
          cubit.continueToNext();
        },
        skip: 4,
        expect: () => [
          const TestCompleted(
            totalQuestions: 1,
            correctAnswersCount: 1,
            incorrectAnswersCount: 0,
          ),
        ],
      );
    });

    group('reset', () {
      blocTest<TestCubit, TestState>(
        'restarts test from beginning',
        build: () {
          when(() => mockNetworkRepository.getQuestions('t-1'))
              .thenAnswer((_) async => [testQuestions[0]]);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadTopic('t-1');
          cubit.selectOption(1);
          cubit.checkAnswer();
          cubit.continueToNext();
          cubit.reset();
        },
        skip: 5,
        expect: () => [
          TestQuestionLoaded(
            question: testQuestions[0],
            currentQuestionIndex: 0,
            totalQuestions: 1,
            selectedOptionIndex: null,
            correctAnswersCount: 0,
          ),
        ],
      );
    });

    test('accuracy calculation works correctly', () {
      const completed = TestCompleted(
        totalQuestions: 10,
        correctAnswersCount: 8,
        incorrectAnswersCount: 2,
      );

      expect(completed.accuracy, 80.0);
    });
  });
}
