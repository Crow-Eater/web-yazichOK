import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_yazichok/data/models/flash_card.dart';
import 'package:web_yazichok/domain/repositories/network_repository.dart';
import 'package:web_yazichok/presentation/flashcards/cubit/memorise_state.dart';

/// Cubit for managing memorisation flow state
class MemoriseCubit extends Cubit<MemoriseState> {
  final NetworkRepository _networkRepository;

  List<FlashCard> _words = [];
  int _currentIndex = 0;
  int _knownCount = 0;
  int _unknownCount = 0;

  MemoriseCubit(this._networkRepository) : super(const MemoriseInitial());

  /// Load words for a specific group
  Future<void> loadGroup(String groupId) async {
    try {
      emit(const MemoriseLoading());
      _words = await _networkRepository.getWordsForGroup(groupId);

      if (_words.isEmpty) {
        emit(const MemoriseEmpty());
        return;
      }

      // Reset counters
      _currentIndex = 0;
      _knownCount = 0;
      _unknownCount = 0;

      // Emit first word
      emit(MemoriseInProgress(
        currentWord: _words[_currentIndex],
        currentIndex: _currentIndex,
        totalWords: _words.length,
        knownCount: _knownCount,
        unknownCount: _unknownCount,
        isTranslationRevealed: false,
      ));
    } catch (e) {
      emit(MemoriseError('Failed to load words: ${e.toString()}'));
    }
  }

  /// Reveal translation for the current word
  void revealTranslation() {
    if (state is MemoriseInProgress) {
      final currentState = state as MemoriseInProgress;
      emit(currentState.copyWith(isTranslationRevealed: true));
    }
  }

  /// Mark current word as known and advance
  void markKnown() {
    if (state is! MemoriseInProgress) return;

    _knownCount++;
    _advanceToNextWord();
  }

  /// Mark current word as unknown and advance
  void markUnknown() {
    if (state is! MemoriseInProgress) return;

    _unknownCount++;
    _advanceToNextWord();
  }

  /// Advance to the next word or show completion
  void _advanceToNextWord() {
    _currentIndex++;

    if (_currentIndex >= _words.length) {
      // All words completed
      emit(MemoriseCompleted(
        totalWords: _words.length,
        knownCount: _knownCount,
        unknownCount: _unknownCount,
      ));
    } else {
      // Show next word
      emit(MemoriseInProgress(
        currentWord: _words[_currentIndex],
        currentIndex: _currentIndex,
        totalWords: _words.length,
        knownCount: _knownCount,
        unknownCount: _unknownCount,
        isTranslationRevealed: false,
      ));
    }
  }

  /// Reset and restart memorisation
  void reset() {
    if (_words.isEmpty) {
      emit(const MemoriseInitial());
      return;
    }

    _currentIndex = 0;
    _knownCount = 0;
    _unknownCount = 0;

    emit(MemoriseInProgress(
      currentWord: _words[_currentIndex],
      currentIndex: _currentIndex,
      totalWords: _words.length,
      knownCount: _knownCount,
      unknownCount: _unknownCount,
      isTranslationRevealed: false,
    ));
  }
}
