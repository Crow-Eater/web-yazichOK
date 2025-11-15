import 'package:flutter/material.dart';

/// Article content widget with formatted text rendering
class ArticleContent extends StatelessWidget {
  final String content;

  const ArticleContent({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Parse content into paragraphs and headings
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      final trimmedLine = line.trim();

      // Skip empty lines
      if (trimmedLine.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Heading (## Heading)
      if (trimmedLine.startsWith('## ')) {
        widgets.add(const SizedBox(height: 24));
        widgets.add(
          Text(
            trimmedLine.substring(3),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 16));
        continue;
      }

      // Main heading (# Heading)
      if (trimmedLine.startsWith('# ')) {
        widgets.add(const SizedBox(height: 24));
        widgets.add(
          Text(
            trimmedLine.substring(2),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 16));
        continue;
      }

      // Regular paragraph
      widgets.add(
        Text(
          trimmedLine,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
            fontSize: 16,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }
}
