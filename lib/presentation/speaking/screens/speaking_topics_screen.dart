import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_yazichok/core/routing/route_names.dart';
import 'package:web_yazichok/presentation/speaking/cubit/speech_cubit.dart';
import 'package:web_yazichok/presentation/speaking/cubit/speech_state.dart';
import 'package:web_yazichok/presentation/speaking/widgets/topic_card.dart';

/// Screen displaying list of speaking practice topics
class SpeakingTopicsScreen extends StatelessWidget {
  const SpeakingTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaking Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push(RouteNames.speakingResults);
            },
            tooltip: 'View Results History',
          ),
        ],
      ),
      body: BlocBuilder<SpeechCubit, SpeechState>(
        builder: (context, state) {
          if (state is SpeechTopicsLoading) {
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
                      context.read<SpeechCubit>().loadTopics();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SpeechTopicsLoaded) {
            if (state.topics.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.speaker_notes_off,
                      size: 64,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Topics Available',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('Check back later for new speaking topics'),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a Topic',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a topic to practice your speaking skills',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.topics.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final topic = state.topics[index];
                        return TopicCard(
                          topic: topic,
                          onTap: () {
                            context.read<SpeechCubit>().selectTopic(topic);
                            context.push(RouteNames.recording);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          // Initial state
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
