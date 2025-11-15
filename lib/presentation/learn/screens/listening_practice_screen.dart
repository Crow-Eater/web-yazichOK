import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yazich_ok/presentation/learn/cubit/listening_cubit.dart';
import 'package:yazich_ok/presentation/learn/cubit/listening_state.dart';
import 'package:yazich_ok/presentation/learn/widgets/audio_player_card.dart';
import 'package:yazich_ok/presentation/learn/widgets/audio_record_list.dart';

/// Screen for listening practice with audio player
class ListeningPracticeScreen extends StatelessWidget {
  const ListeningPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening Practice'),
      ),
      body: BlocBuilder<ListeningCubit, ListeningState>(
        builder: (context, state) {
          if (state is ListeningLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ListeningError) {
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
                      context.read<ListeningCubit>().loadRecords();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ListeningLoaded) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Audio Player Card
                  AudioPlayerCard(
                    audioRecord: state.selectedRecord,
                    isPlaying: state.isPlaying,
                    position: state.position,
                    duration: state.duration,
                    onPlayPause: () {
                      if (state.isPlaying) {
                        context.read<ListeningCubit>().pause();
                      } else {
                        context.read<ListeningCubit>().play();
                      }
                    },
                    onSeekBackward: () {
                      context.read<ListeningCubit>().seekBackward(10);
                    },
                    onSeekForward: () {
                      context.read<ListeningCubit>().seekForward(10);
                    },
                    onSeek: (value) {
                      final position =
                          Duration(milliseconds: value.toInt());
                      context.read<ListeningCubit>().seekTo(position);
                    },
                  ),

                  // Section header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Available Audio',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Audio Records List
                  AudioRecordList(
                    records: state.records,
                    selectedRecord: state.selectedRecord,
                    onRecordTap: (record) {
                      context.read<ListeningCubit>().selectRecord(record);
                    },
                  ),

                  const SizedBox(height: 16),
                ],
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
