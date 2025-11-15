import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yazich_ok/data/models/flash_card.dart';
import 'package:yazich_ok/data/models/word_group.dart';
import 'package:yazich_ok/domain/repositories/network_repository.dart';
import 'package:yazich_ok/presentation/flashcards/cubit/flashcards_state.dart';

/// Cubit for managing FlashCards feature state
class FlashCardsCubit extends Cubit<FlashCardsState> {
  final NetworkRepository _networkRepository;

  FlashCardsCubit(this._networkRepository) : super(const FlashCardsInitial());

  /// Load all word groups
  Future<void> loadGroups() async {
    try {
      emit(const FlashCardsLoading());
      final groups = await _networkRepository.getFlashcardGroups();
      emit(FlashCardsLoaded(groups));
    } catch (e) {
      emit(FlashCardsError('Failed to load word groups: ${e.toString()}'));
    }
  }

  /// Add a new word group
  Future<void> addGroup(String name) async {
    try {
      emit(const FlashCardsLoading());
      await _networkRepository.addFlashcardGroup(name);
      // Reload groups after adding
      await loadGroups();
    } catch (e) {
      emit(FlashCardsError('Failed to add group: ${e.toString()}'));
    }
  }

  /// Add a word to a specific group
  Future<void> addWord(String groupId, FlashCard word) async {
    try {
      emit(const FlashCardsLoading());
      await _networkRepository.addWord(groupId, word);
      // Reload groups after adding word
      await loadGroups();
    } catch (e) {
      emit(FlashCardsError('Failed to add word: ${e.toString()}'));
    }
  }

  /// Delete a word group
  Future<void> deleteGroup(String groupId) async {
    try {
      emit(const FlashCardsLoading());
      await _networkRepository.deleteGroup(groupId);
      // Reload groups after deletion
      await loadGroups();
    } catch (e) {
      emit(FlashCardsError('Failed to delete group: ${e.toString()}'));
    }
  }

  /// Delete a word
  Future<void> deleteWord(String wordId) async {
    try {
      emit(const FlashCardsLoading());
      await _networkRepository.deleteWord(wordId);
      // Reload groups after deletion
      await loadGroups();
    } catch (e) {
      emit(FlashCardsError('Failed to delete word: ${e.toString()}'));
    }
  }

  /// Get words for a specific group
  Future<List<FlashCard>> getWordsForGroup(String groupId) async {
    try {
      return await _networkRepository.getWordsForGroup(groupId);
    } catch (e) {
      emit(FlashCardsError('Failed to load words: ${e.toString()}'));
      return [];
    }
  }
}
