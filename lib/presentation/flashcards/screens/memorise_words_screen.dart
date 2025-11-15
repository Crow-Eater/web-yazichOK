import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yazich_ok/core/routing/route_names.dart';
import 'package:yazich_ok/presentation/flashcards/cubit/memorise_cubit.dart';
import 'package:yazich_ok/presentation/flashcards/cubit/memorise_state.dart';
import 'package:yazich_ok/presentation/flashcards/widgets/flashcard_widget.dart';
import 'package:yazich_ok/presentation/flashcards/widgets/statistics_card.dart';

/// Screen for memorizing words from a group
/// Shows flashcards one at a time with know/don't know options
class MemoriseWordsScreen extends StatelessWidget {
  final String groupId;

  const MemoriseWordsScreen({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorise Words'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.flashcards),
        ),
      ),
      body: BlocBuilder<MemoriseCubit, MemoriseState>(
        builder: (context, state) {
          if (state is MemoriseLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is MemoriseError) {
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
                      context.read<MemoriseCubit>().loadGroup(groupId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is MemoriseEmpty) {
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
                    'No Words in This Group',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some words to start practicing',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push(Routes.addWord),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Words'),
                  ),
                ],
              ),
            );
          }

          if (state is MemoriseCompleted) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: StatisticsCard(
                  totalWords: state.totalWords,
                  knownCount: state.knownCount,
                  unknownCount: state.unknownCount,
                  onRestart: () {
                    context.read<MemoriseCubit>().reset();
                  },
                  onBackToGroups: () {
                    context.go(Routes.flashcards);
                  },
                ),
              ),
            );
          }

          if (state is MemoriseInProgress) {
            return Column(
              children: [
                // Progress indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Card ${state.currentIndex + 1} of ${state.totalWords}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              _ProgressChip(
                                icon: Icons.check_circle,
                                color: Colors.green,
                                count: state.knownCount,
                              ),
                              const SizedBox(width: 8),
                              _ProgressChip(
                                icon: Icons.cancel,
                                color: Colors.red,
                                count: state.unknownCount,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (state.currentIndex + 1) / state.totalWords,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),

                // Flashcard
                Expanded(
                  child: Center(
                    child: FlashcardWidget(
                      flashCard: state.currentWord,
                      isTranslationRevealed: state.isTranslationRevealed,
                      onRevealTranslation: () {
                        context.read<MemoriseCubit>().revealTranslation();
                      },
                    ),
                  ),
                ),

                // Action buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<MemoriseCubit>().markUnknown();
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Don\'t Know'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<MemoriseCubit>().markKnown();
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Know'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

class _ProgressChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;

  const _ProgressChip({
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
