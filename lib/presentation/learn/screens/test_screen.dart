import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_yazichok/core/routing/route_names.dart';
import 'package:web_yazichok/presentation/learn/cubit/test_cubit.dart';
import 'package:web_yazichok/presentation/learn/cubit/test_state.dart';
import 'package:web_yazichok/presentation/learn/widgets/question_card.dart';
import 'package:web_yazichok/presentation/learn/widgets/result_card.dart';
import 'package:web_yazichok/presentation/learn/widgets/summary_card.dart';

/// Screen for taking a grammar test
class TestScreen extends StatelessWidget {
  final String topicId;

  const TestScreen({
    super.key,
    required this.topicId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar Test'),
      ),
      body: BlocBuilder<TestCubit, TestState>(
        builder: (context, state) {
          if (state is TestLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is TestError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TestCubit>().loadTopic(topicId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TestQuestionLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${state.currentQuestionIndex + 1} of ${state.totalQuestions}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Score: ${state.correctAnswersCount}/${state.currentQuestionIndex}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: (state.currentQuestionIndex + 1) /
                              state.totalQuestions,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),

                  // Question Card
                  QuestionCard(
                    question: state.question,
                    selectedOptionIndex: state.selectedOptionIndex,
                    onOptionSelected: (index) {
                      context.read<TestCubit>().selectOption(index);
                    },
                    onCheckAnswer: () {
                      context.read<TestCubit>().checkAnswer();
                    },
                    canCheck: state.hasSelectedAnswer,
                  ),
                ],
              ),
            );
          }

          if (state is TestResultShown) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${state.currentQuestionIndex + 1} of ${state.totalQuestions}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Score: ${state.correctAnswersCount}/${state.currentQuestionIndex + 1}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: (state.currentQuestionIndex + 1) /
                              state.totalQuestions,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),

                  // Result Card
                  ResultCard(
                    question: state.question,
                    selectedOptionIndex: state.selectedOptionIndex,
                    isCorrect: state.isCorrect,
                    explanation: state.explanation,
                    onContinue: () {
                      context.read<TestCubit>().continueToNext();
                    },
                  ),
                ],
              ),
            );
          }

          if (state is TestCompleted) {
            return SingleChildScrollView(
              child: SummaryCard(
                totalQuestions: state.totalQuestions,
                correctAnswersCount: state.correctAnswersCount,
                incorrectAnswersCount: state.incorrectAnswersCount,
                onRetake: () {
                  context.read<TestCubit>().reset();
                },
                onBackToTopics: () {
                  context.go(RouteNames.grammarTopics);
                },
              ),
            );
          }

          // Initial state
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
