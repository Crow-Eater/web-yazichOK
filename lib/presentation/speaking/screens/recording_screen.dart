import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yazich_ok/core/routing/route_names.dart';
import 'package:yazich_ok/presentation/speaking/cubit/speech_cubit.dart';
import 'package:yazich_ok/presentation/speaking/cubit/speech_state.dart';
import 'package:yazich_ok/presentation/speaking/widgets/recording_controls.dart';

/// Screen for recording speech on a selected topic
class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Your Response'),
      ),
      body: BlocConsumer<SpeechCubit, SpeechState>(
        listener: (context, state) {
          // Navigate to assessment screen when recording is submitted
          if (state is SpeechAssessmentProcessing) {
            context.push(Routes.assessment);
          }
        },
        builder: (context, state) {
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
                      context.pop();
                    },
                    child: const Text('Back to Topics'),
                  ),
                ],
              ),
            );
          }

          if (state is! SpeechRecordingIdle &&
              state is! SpeechRecording &&
              state is! SpeechRecordingStopped) {
            // Redirect back if in wrong state
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.pop();
            });
            return const SizedBox.shrink();
          }

          final topic = state is SpeechRecordingIdle
              ? state.topic
              : state is SpeechRecording
                  ? state.topic
                  : (state as SpeechRecordingStopped).topic;

          final isRecording = state is SpeechRecording;
          final isStopped = state is SpeechRecordingStopped;
          final recordingDuration = isRecording
              ? state.recordingDuration
              : isStopped
                  ? state.recordingDuration
                  : 0;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Topic Card
                  Card(
                    elevation: 2,
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.topic,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Topic',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            topic.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            topic.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: theme.colorScheme.onPrimaryContainer
                                    .withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Time limit: ${_formatDuration(topic.timeLimit)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Recording Timer Display
                  Center(
                    child: Column(
                      children: [
                        Text(
                          isRecording
                              ? 'Recording...'
                              : isStopped
                                  ? 'Recording Complete'
                                  : 'Ready to Record',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _formatDuration(recordingDuration),
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFeatures: [
                              const FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Progress indicator for recording
                        if (isRecording)
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: recordingDuration / topic.timeLimit,
                              backgroundColor:
                                  theme.colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Recording Controls
                  RecordingControls(
                    isRecording: isRecording,
                    isStopped: isStopped,
                    onStartRecording: () {
                      context.read<SpeechCubit>().startRecording();
                    },
                    onStopRecording: () {
                      context.read<SpeechCubit>().stopRecording();
                    },
                    onReRecord: () {
                      context.read<SpeechCubit>().reRecord();
                    },
                    onSubmit: () {
                      context.read<SpeechCubit>().submitRecording();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
