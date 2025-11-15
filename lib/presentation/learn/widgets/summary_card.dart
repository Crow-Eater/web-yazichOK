import 'package:flutter/material.dart';

/// Widget for displaying test summary/results
class SummaryCard extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswersCount;
  final int incorrectAnswersCount;
  final VoidCallback onRetake;
  final VoidCallback onBackToTopics;

  const SummaryCard({
    super.key,
    required this.totalQuestions,
    required this.correctAnswersCount,
    required this.incorrectAnswersCount,
    required this.onRetake,
    required this.onBackToTopics,
  });

  double get accuracy =>
      totalQuestions > 0 ? (correctAnswersCount / totalQuestions) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Completion icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accuracy >= 70
                    ? Colors.green.withOpacity(0.1)
                    : accuracy >= 50
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                accuracy >= 70
                    ? Icons.celebration
                    : accuracy >= 50
                        ? Icons.thumb_up
                        : Icons.trending_up,
                size: 40,
                color: accuracy >= 70
                    ? Colors.green
                    : accuracy >= 50
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Test Complete!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Accuracy percentage
            Text(
              '${accuracy.toStringAsFixed(0)}% Score',
              style: theme.textTheme.titleLarge?.copyWith(
                color: accuracy >= 70
                    ? Colors.green
                    : accuracy >= 50
                        ? Colors.orange
                        : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),

            // Statistics grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  label: 'Correct',
                  value: correctAnswersCount.toString(),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                _StatItem(
                  icon: Icons.cancel,
                  iconColor: Colors.red,
                  label: 'Incorrect',
                  value: incorrectAnswersCount.toString(),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                _StatItem(
                  icon: Icons.quiz,
                  iconColor: theme.colorScheme.primary,
                  label: 'Total',
                  value: totalQuestions.toString(),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Performance message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                accuracy >= 70
                    ? 'Excellent work! Keep it up!'
                    : accuracy >= 50
                        ? 'Good effort! A bit more practice will help.'
                        : 'Keep practicing! You\'ll improve with time.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            ElevatedButton.icon(
              onPressed: onRetake,
              icon: const Icon(Icons.refresh),
              label: const Text('Retake Test'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onBackToTopics,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Topics'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
