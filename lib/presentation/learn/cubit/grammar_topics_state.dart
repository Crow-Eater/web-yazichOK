import 'package:equatable/equatable.dart';
import 'package:web_yazichok/data/models/grammar_topic.dart';

/// Base state for Grammar Topics feature
abstract class GrammarTopicsState extends Equatable {
  const GrammarTopicsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class GrammarTopicsInitial extends GrammarTopicsState {
  const GrammarTopicsInitial();
}

/// Loading state while fetching topics
class GrammarTopicsLoading extends GrammarTopicsState {
  const GrammarTopicsLoading();
}

/// Loaded state with topics data
class GrammarTopicsLoaded extends GrammarTopicsState {
  final List<GrammarTopic> topics;

  const GrammarTopicsLoaded(this.topics);

  @override
  List<Object?> get props => [topics];
}

/// Error state
class GrammarTopicsError extends GrammarTopicsState {
  final String message;

  const GrammarTopicsError(this.message);

  @override
  List<Object?> get props => [message];
}
