import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_yazichok/presentation/speaking/cubit/speech_cubit.dart';
import 'package:web_yazichok/presentation/speaking/cubit/speech_state.dart';
import 'package:web_yazichok/presentation/speaking/widgets/results_history_item.dart';
import 'package:web_yazichok/presentation/speaking/widgets/statistics_section.dart';

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
                ? state.results
                        .map((r) => r.overallScore)
                        .reduce((a, b) => a + b) ~/
                    state.results.length
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
                          result: result,
                          topicTitle: topic?.title ?? 'Unknown Topic',
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
}
