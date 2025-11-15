import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yazich_ok/core/routing/route_names.dart';
import 'package:yazich_ok/presentation/learn/cubit/grammar_topics_cubit.dart';
import 'package:yazich_ok/presentation/learn/cubit/grammar_topics_state.dart';
import 'package:yazich_ok/presentation/learn/widgets/topic_list_item.dart';

/// Screen displaying list of grammar topics
class GrammarTopicsScreen extends StatelessWidget {
  const GrammarTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar Topics'),
      ),
      body: BlocBuilder<GrammarTopicsCubit, GrammarTopicsState>(
        builder: (context, state) {
          if (state is GrammarTopicsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is GrammarTopicsError) {
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
                      context.read<GrammarTopicsCubit>().loadTopics();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is GrammarTopicsLoaded) {
            if (state.topics.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 80,
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Topics Available',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new topics',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.topics.length,
              itemBuilder: (context, index) {
                final topic = state.topics[index];
                return TopicListItem(
                  topic: topic,
                  onTap: () {
                    context.push('${Routes.learn}/test/${topic.id}');
                  },
                );
              },
            );
          }

          // Initial state
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
