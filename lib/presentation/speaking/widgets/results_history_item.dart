import 'package:flutter/material.dart';
import 'package:web_yazichok/data/models/assessment_result.dart';
import 'package:intl/intl.dart';

/// List item widget for displaying a single assessment result
class ResultsHistoryItem extends StatelessWidget {
  final AssessmentResult result;
  final String topicTitle;

  const ResultsHistoryItem({
    super.key,
    required this.result,
    required this.topicTitle,
  });

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = _getScoreColor(result.overallScore);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Score Circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withOpacity(0.2),
                border: Border.all(
                  color: scoreColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${result.overallScore}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topicTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(result.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Mini score breakdown
                  Row(
                    children: [
                      _buildMiniScore(
                        context,
                        'P',
                        result.pronunciationScore,
                      ),
                      const SizedBox(width: 8),
                      _buildMiniScore(
                        context,
                        'F',
                        result.fluencyScore,
                      ),
                      const SizedBox(width: 8),
                      _buildMiniScore(
                        context,
                        'A',
                        result.accuracyScore,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniScore(BuildContext context, String label, int score) {
    final theme = Theme.of(context);
    final scoreColor = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $score',
        style: theme.textTheme.bodySmall?.copyWith(
          color: scoreColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
