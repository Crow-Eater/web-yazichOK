import 'package:equatable/equatable.dart';
import 'package:yazich_ok/data/models/question.dart';

/// Base state for Test feature
abstract class TestState extends Equatable {
  const TestState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TestInitial extends TestState {
  const TestInitial();
}

/// Loading state while fetching questions
class TestLoading extends TestState {
  const TestLoading();
}

/// State when showing a question (before checking answer)
class TestQuestionLoaded extends TestState {
  final Question question;
  final int currentQuestionIndex;
  final int totalQuestions;
  final int? selectedOptionIndex;
  final int correctAnswersCount;

  const TestQuestionLoaded({
    required this.question,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    this.selectedOptionIndex,
    required this.correctAnswersCount,
  });

  bool get hasSelectedAnswer => selectedOptionIndex != null;

  @override
  List<Object?> get props => [
        question,
        currentQuestionIndex,
        totalQuestions,
        selectedOptionIndex,
        correctAnswersCount,
      ];

  TestQuestionLoaded copyWith({
    Question? question,
    int? currentQuestionIndex,
    int? totalQuestions,
    int? selectedOptionIndex,
    int? correctAnswersCount,
    bool clearSelection = false,
  }) {
    return TestQuestionLoaded(
      question: question ?? this.question,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      selectedOptionIndex:
          clearSelection ? null : (selectedOptionIndex ?? this.selectedOptionIndex),
      correctAnswersCount: correctAnswersCount ?? this.correctAnswersCount,
    );
  }
}

/// State when showing result after checking answer
class TestResultShown extends TestState {
  final Question question;
  final int selectedOptionIndex;
  final bool isCorrect;
  final String? explanation;
  final int currentQuestionIndex;
  final int totalQuestions;
  final int correctAnswersCount;

  const TestResultShown({
    required this.question,
    required this.selectedOptionIndex,
    required this.isCorrect,
    this.explanation,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.correctAnswersCount,
  });

  @override
  List<Object?> get props => [
        question,
        selectedOptionIndex,
        isCorrect,
        explanation,
        currentQuestionIndex,
        totalQuestions,
        correctAnswersCount,
      ];
}

/// State when test is completed (all questions answered)
class TestCompleted extends TestState {
  final int totalQuestions;
  final int correctAnswersCount;
  final int incorrectAnswersCount;

  const TestCompleted({
    required this.totalQuestions,
    required this.correctAnswersCount,
    required this.incorrectAnswersCount,
  });

  double get accuracy =>
      totalQuestions > 0 ? (correctAnswersCount / totalQuestions) * 100 : 0;

  @override
  List<Object?> get props =>
      [totalQuestions, correctAnswersCount, incorrectAnswersCount];
}

/// Error state
class TestError extends TestState {
  final String message;

  const TestError(this.message);

  @override
  List<Object?> get props => [message];
}
