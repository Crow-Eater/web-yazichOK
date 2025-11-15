import 'package:flutter/material.dart';

/// Widget for displaying memorization statistics
class StatisticsCard extends StatelessWidget {
  final int totalWords;
  final int knownCount;
  final int unknownCount;
  final VoidCallback onRestart;
  final VoidCallback onBackToGroups;

  const StatisticsCard({
    super.key,
    required this.totalWords,
    required this.knownCount,
    required this.unknownCount,
    required this.onRestart,
    required this.onBackToGroups,
  });

  double get accuracy => totalWords > 0 ? (knownCount / totalWords) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Completion icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: accuracy >= 70
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              accuracy >= 70 ? Icons.celebration : Icons.trending_up,
              size: 40,
              color: accuracy >= 70 ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Session Complete!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Accuracy percentage
          Text(
            '${accuracy.toStringAsFixed(0)}% Accuracy',
            style: theme.textTheme.titleLarge?.copyWith(
              color: accuracy >= 70 ? Colors.green : Colors.orange,
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
                label: 'Known',
                value: knownCount.toString(),
              ),
              Container(
                width: 1,
                height: 50,
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              _StatItem(
                icon: Icons.cancel,
                iconColor: Colors.red,
                label: 'Unknown',
                value: unknownCount.toString(),
              ),
              Container(
                width: 1,
                height: 50,
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              _StatItem(
                icon: Icons.library_books,
                iconColor: theme.colorScheme.primary,
                label: 'Total',
                value: totalWords.toString(),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Action buttons
          ElevatedButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh),
            label: const Text('Practice Again'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onBackToGroups,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Groups'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
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
