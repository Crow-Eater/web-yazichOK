import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yazich_ok/presentation/speaking/cubit/speech_cubit.dart';
import 'package:yazich_ok/presentation/speaking/cubit/speech_state.dart';
import 'package:yazich_ok/presentation/speaking/widgets/assessment_results_card.dart';

/// Screen for displaying speaking assessment results
class SpeakingAssessmentScreen extends StatelessWidget {
  const SpeakingAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<SpeechCubit, SpeechState>(
        builder: (context, state) {
          print('DEBUG: AssessmentScreen building with state: ${state.runtimeType}');
          if (state is SpeechAssessmentProcessing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Analyzing Your Speech...',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please wait while we assess your recording',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is SpeechAssessmentCompleted) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Success icon
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primaryContainer,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 60,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Assessment Complete!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here are your speaking assessment results',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Assessment Results Card
                    AssessmentResultsCard(
                      result: state.result,
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Go back to recording screen to try again
                              context.read<SpeechCubit>().reRecord();
                              context.pop();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<SpeechCubit>().backToTopics();
                              // Pop until back to topics screen
                              while (context.canPop()) {
                                context.pop();
                              }
                            },
                            icon: const Icon(Icons.home),
                            label: const Text('Back to Topics'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                    'Assessment Failed',
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
                      context.pop();
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          // Fallback - shouldn't normally reach here
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
