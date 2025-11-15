import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yazich_ok/core/routing/route_names.dart';
import 'package:yazich_ok/presentation/flashcards/cubit/flashcards_cubit.dart';
import 'package:yazich_ok/presentation/flashcards/cubit/flashcards_state.dart';
import 'package:yazich_ok/presentation/flashcards/widgets/group_list_item.dart';

/// Main screen for FlashCards feature
/// Displays list of word groups and navigation to add words/groups
class FlashCardsScreen extends StatelessWidget {
  const FlashCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flash Cards'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.main),
        ),
        actions: [
          // Plus icon to add new word
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.addWord),
            tooltip: 'Add New Word',
          ),
        ],
      ),
      body: BlocBuilder<FlashCardsCubit, FlashCardsState>(
        builder: (context, state) {
          if (state is FlashCardsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is FlashCardsError) {
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
                      context.read<FlashCardsCubit>().loadGroups();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is FlashCardsLoaded) {
            if (state.groups.isEmpty) {
              // Empty state
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 80,
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Word Groups',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first group to start learning',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push(Routes.addGroup),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Group'),
                    ),
                  ],
                ),
              );
            }

            // List of word groups
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                final group = state.groups[index];
                return GroupListItem(
                  group: group,
                  onTap: () {
                    context.push('${Routes.flashcards}/group/${group.id}');
                  },
                );
              },
            );
          }

          // Initial state
          return const SizedBox.shrink();
        },
      ),
      // Floating action button for adding new group
      floatingActionButton: BlocBuilder<FlashCardsCubit, FlashCardsState>(
        builder: (context, state) {
          // Only show FAB when groups are loaded (including empty state)
          if (state is FlashCardsLoaded) {
            return FloatingActionButton(
              onPressed: () => context.push(Routes.addGroup),
              tooltip: 'Add New Group',
              child: const Icon(Icons.folder_open),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
