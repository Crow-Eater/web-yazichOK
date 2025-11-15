import 'package:equatable/equatable.dart';
import 'package:yazich_ok/data/models/word_group.dart';

/// Base state for FlashCards feature
abstract class FlashCardsState extends Equatable {
  const FlashCardsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when FlashCards screen is first opened
class FlashCardsInitial extends FlashCardsState {
  const FlashCardsInitial();
}

/// Loading state while fetching word groups
class FlashCardsLoading extends FlashCardsState {
  const FlashCardsLoading();
}

/// Loaded state with word groups data
class FlashCardsLoaded extends FlashCardsState {
  final List<WordGroup> groups;

  const FlashCardsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

/// Error state when something goes wrong
class FlashCardsError extends FlashCardsState {
  final String message;

  const FlashCardsError(this.message);

  @override
  List<Object?> get props => [message];
}
