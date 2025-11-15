import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yazich_ok/core/routing/route_names.dart';
import 'package:yazich_ok/presentation/learn/widgets/learning_option_card.dart';

/// Main Learn screen - hub for grammar tests and listening practice
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.main),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Learning Path',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select an activity to improve your language skills',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grammar Tests option
            LearningOptionCard(
              title: 'Grammar Tests',
              description: 'Practice grammar with interactive exercises',
              icon: Icons.quiz,
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade400,
                  Colors.deepOrange.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => context.push(Routes.grammarTopics),
            ),

            // Listening Practice option
            LearningOptionCard(
              title: 'Listening Practice',
              description: 'Improve comprehension with audio exercises',
              icon: Icons.headphones,
              gradient: LinearGradient(
                colors: [
                  Colors.teal.shade400,
                  Colors.cyan.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => context.push(Routes.listening),
            ),
          ],
        ),
      ),
    );
  }
}
