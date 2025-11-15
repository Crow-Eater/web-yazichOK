import 'package:equatable/equatable.dart';
import 'package:yazich_ok/data/models/audio_record.dart';

/// Base state for Listening Practice feature
abstract class ListeningState extends Equatable {
  const ListeningState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ListeningInitial extends ListeningState {
  const ListeningInitial();
}

/// Loading state while fetching audio records
class ListeningLoading extends ListeningState {
  const ListeningLoading();
}

/// State when audio records are loaded
class ListeningLoaded extends ListeningState {
  final List<AudioRecord> records;
  final AudioRecord? selectedRecord;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const ListeningLoaded({
    required this.records,
    this.selectedRecord,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  @override
  List<Object?> get props => [
        records,
        selectedRecord,
        isPlaying,
        position,
        duration,
      ];

  ListeningLoaded copyWith({
    List<AudioRecord>? records,
    AudioRecord? selectedRecord,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool clearSelection = false,
  }) {
    return ListeningLoaded(
      records: records ?? this.records,
      selectedRecord: clearSelection
          ? null
          : (selectedRecord ?? this.selectedRecord),
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

/// Error state
class ListeningError extends ListeningState {
  final String message;

  const ListeningError(this.message);

  @override
  List<Object?> get props => [message];
}
