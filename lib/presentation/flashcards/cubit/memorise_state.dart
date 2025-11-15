import 'package:equatable/equatable.dart';
import 'package:web_yazichok/data/models/flash_card.dart';

/// Base state for Memorise feature
abstract class MemoriseState extends Equatable {
  const MemoriseState();

  @override
  List<Object?> get props => [];
}

/// Initial state when memorisation screen is first opened
class MemoriseInitial extends MemoriseState {
  const MemoriseInitial();
}

/// Loading state while fetching words
class MemoriseLoading extends MemoriseState {
  const MemoriseLoading();
}

/// State when memorisation is in progress
class MemoriseInProgress extends MemoriseState {
  final FlashCard currentWord;
  final int currentIndex;
  final int totalWords;
  final int knownCount;
  final int unknownCount;
  final bool isTranslationRevealed;

  const MemoriseInProgress({
    required this.currentWord,
    required this.currentIndex,
    required this.totalWords,
    required this.knownCount,
    required this.unknownCount,
    required this.isTranslationRevealed,
  });

  @override
  List<Object?> get props => [
        currentWord,
        currentIndex,
        totalWords,
        knownCount,
        unknownCount,
        isTranslationRevealed,
      ];

  MemoriseInProgress copyWith({
    FlashCard? currentWord,
    int? currentIndex,
    int? totalWords,
    int? knownCount,
    int? unknownCount,
    bool? isTranslationRevealed,
  }) {
    return MemoriseInProgress(
      currentWord: currentWord ?? this.currentWord,
      currentIndex: currentIndex ?? this.currentIndex,
      totalWords: totalWords ?? this.totalWords,
      knownCount: knownCount ?? this.knownCount,
      unknownCount: unknownCount ?? this.unknownCount,
      isTranslationRevealed: isTranslationRevealed ?? this.isTranslationRevealed,
    );
  }
}

/// State when memorisation is completed (all words reviewed)
class MemoriseCompleted extends MemoriseState {
  final int totalWords;
  final int knownCount;
  final int unknownCount;

  const MemoriseCompleted({
    required this.totalWords,
    required this.knownCount,
    required this.unknownCount,
  });

  double get accuracy => totalWords > 0 ? (knownCount / totalWords) * 100 : 0;

  @override
  List<Object?> get props => [totalWords, knownCount, unknownCount];
}

/// Error state
class MemoriseError extends MemoriseState {
  final String message;

  const MemoriseError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty state when group has no words
class MemoriseEmpty extends MemoriseState {
  const MemoriseEmpty();
}
