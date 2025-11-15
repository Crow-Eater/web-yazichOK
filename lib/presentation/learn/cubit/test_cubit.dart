import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yazich_ok/data/models/question.dart';
import 'package:yazich_ok/domain/repositories/network_repository.dart';
import 'package:yazich_ok/presentation/learn/cubit/test_state.dart';

/// Cubit for managing Test flow state
class TestCubit extends Cubit<TestState> {
  final NetworkRepository _networkRepository;

  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswersCount = 0;

  TestCubit(this._networkRepository) : super(const TestInitial());

  /// Load questions for a specific topic
  Future<void> loadTopic(String topicId) async {
    try {
      emit(const TestLoading());
      _questions = await _networkRepository.getQuestions(topicId);

      if (_questions.isEmpty) {
        emit(const TestError('No questions available for this topic'));
        return;
      }

      // Reset counters
      _currentQuestionIndex = 0;
      _correctAnswersCount = 0;

      // Emit first question
      emit(TestQuestionLoaded(
        question: _questions[_currentQuestionIndex],
        currentQuestionIndex: _currentQuestionIndex,
        totalQuestions: _questions.length,
        selectedOptionIndex: null,
        correctAnswersCount: _correctAnswersCount,
      ));
    } catch (e) {
      emit(TestError('Failed to load questions: ${e.toString()}'));
    }
  }

  /// Select an answer option
  void selectOption(int optionIndex) {
    if (state is TestQuestionLoaded) {
      final currentState = state as TestQuestionLoaded;
      emit(currentState.copyWith(selectedOptionIndex: optionIndex));
    }
  }

  /// Check the selected answer
  void checkAnswer() {
    if (state is! TestQuestionLoaded) return;

    final currentState = state as TestQuestionLoaded;
    if (currentState.selectedOptionIndex == null) return;

    final question = currentState.question;
    final selectedIndex = currentState.selectedOptionIndex!;
    final isCorrect = selectedIndex == question.correctIndex;

    if (isCorrect) {
      _correctAnswersCount++;
    }

    emit(TestResultShown(
      question: question,
      selectedOptionIndex: selectedIndex,
      isCorrect: isCorrect,
      explanation: question.explanation,
      currentQuestionIndex: _currentQuestionIndex,
      totalQuestions: _questions.length,
      correctAnswersCount: _correctAnswersCount,
    ));
  }

  /// Continue to next question or show summary
  void continueToNext() {
    if (state is! TestResultShown) return;

    _currentQuestionIndex++;

    if (_currentQuestionIndex >= _questions.length) {
      // All questions completed - show summary
      emit(TestCompleted(
        totalQuestions: _questions.length,
        correctAnswersCount: _correctAnswersCount,
        incorrectAnswersCount: _questions.length - _correctAnswersCount,
      ));
    } else {
      // Show next question
      emit(TestQuestionLoaded(
        question: _questions[_currentQuestionIndex],
        currentQuestionIndex: _currentQuestionIndex,
        totalQuestions: _questions.length,
        selectedOptionIndex: null,
        correctAnswersCount: _correctAnswersCount,
      ));
    }
  }

  /// Reset and restart the test
  void reset() {
    if (_questions.isEmpty) {
      emit(const TestInitial());
      return;
    }

    _currentQuestionIndex = 0;
    _correctAnswersCount = 0;

    emit(TestQuestionLoaded(
      question: _questions[_currentQuestionIndex],
      currentQuestionIndex: _currentQuestionIndex,
      totalQuestions: _questions.length,
      selectedOptionIndex: null,
      correctAnswersCount: _correctAnswersCount,
    ));
  }
}
