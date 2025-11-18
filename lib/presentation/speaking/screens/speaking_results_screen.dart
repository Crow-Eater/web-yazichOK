import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yazich_ok/data/models/assessment_result.dart';
import 'package:yazich_ok/presentation/speaking/cubit/speech_cubit.dart';
import 'package:yazich_ok/presentation/speaking/cubit/speech_state.dart';
import 'package:yazich_ok/presentation/speaking/widgets/results_history_item.dart';
import 'package:yazich_ok/presentation/speaking/widgets/statistics_section.dart';

/// Screen for viewing speaking assessment results history
class SpeakingResultsScreen extends StatelessWidget {
  const SpeakingResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results History'),
      ),
      body: BlocBuilder<SpeechCubit, SpeechState>(
        builder: (context, state) {
          if (state is SpeechResultsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SpeechError) {
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
                      context.read<SpeechCubit>().loadResultsHistory();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SpeechResultsLoaded) {
            if (state.results.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_edu,
                      size: 64,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Results Yet',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Complete a speaking practice to see your results here',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Calculate statistics
            final avgScore = state.results.isNotEmpty
                ? (state.results
                        .map((r) => r.overallScore)
                        .reduce((a, b) => a + b) /
                    state.results.length).round()
                : 0;

            final totalAttempts = state.results.length;

            // Recent results (last 5)
            final recentResults = state.results.take(5).toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Section
                    StatisticsSection(
                      totalAttempts: totalAttempts,
                      averageScore: avgScore,
                    ),
                    const SizedBox(height: 32),

                    // Recent Results Header
                    Text(
                      'Recent Results',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Results List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentResults.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final result = recentResults[index];
                        final topic = state.topicMap[result.topicId];

                        return ResultsHistoryItem(
                          key: ValueKey(result.id),
                          result: result,
                          topicTitle: topic?.title ?? 'Unknown Topic',
                          onTap: () {
                            _showResultDetails(context, result, topic?.title ?? 'Unknown Topic');
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          // Initial or other states
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  void _showResultDetails(BuildContext context, AssessmentResult result, String topicTitle) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Assessment Result',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Topic Title
                Text(
                  topicTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Overall Score
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overall Score',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${result.overallScore}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Score Breakdown
                _buildScoreRow(context, 'Pronunciation', result.pronunciationScore),
                const SizedBox(height: 12),
                _buildScoreRow(context, 'Fluency', result.fluencyScore),
                const SizedBox(height: 12),
                _buildScoreRow(context, 'Accuracy', result.accuracyScore),
                const SizedBox(height: 24),

                // Feedback
                if (result.feedback.isNotEmpty) ...[
                  Text(
                    'Feedback',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result.feedback,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Close Button
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(BuildContext context, String label, int score) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    score >= 80 ? Colors.green :
                    score >= 60 ? Colors.orange :
                    Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 30,
                child: Text(
                  '$score',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
