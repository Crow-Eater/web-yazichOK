import 'package:flutter/material.dart';
import 'package:yazich_ok/data/models/assessment_result.dart';

/// Card widget for displaying assessment results with scores
class AssessmentResultsCard extends StatelessWidget {
  final AssessmentResult result;

  const AssessmentResultsCard({
    super.key,
    required this.result,
  });

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(int score) {
    if (score >= 80) return Icons.emoji_events;
    if (score >= 60) return Icons.thumb_up;
    return Icons.trending_up;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = _getScoreColor(result.overallScore);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall Score
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scoreColor.withOpacity(0.2),
                    scoreColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scoreColor,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getScoreIcon(result.overallScore),
                    size: 48,
                    color: scoreColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Overall Score',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${result.overallScore}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    'out of 100',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Score Breakdown
            Text(
              'Score Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildScoreItem(
              context,
              'Pronunciation',
              result.pronunciationScore,
              Icons.record_voice_over,
            ),
            const SizedBox(height: 12),

            _buildScoreItem(
              context,
              'Fluency',
              result.fluencyScore,
              Icons.speed,
            ),
            const SizedBox(height: 12),

            _buildScoreItem(
              context,
              'Accuracy',
              result.accuracyScore,
              Icons.check_circle_outline,
            ),
            const SizedBox(height: 24),

            // Feedback
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.feedback,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Feedback',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.feedback,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(
    BuildContext context,
    String label,
    int score,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final scoreColor = _getScoreColor(score);

    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$score/100',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: score / 100,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
