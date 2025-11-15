import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yazich_ok/domain/repositories/network_repository.dart';
import 'package:yazich_ok/presentation/learn/cubit/grammar_topics_state.dart';

/// Cubit for managing Grammar Topics state
class GrammarTopicsCubit extends Cubit<GrammarTopicsState> {
  final NetworkRepository _networkRepository;

  GrammarTopicsCubit(this._networkRepository)
      : super(const GrammarTopicsInitial());

  /// Load all grammar topics
  Future<void> loadTopics() async {
    try {
      emit(const GrammarTopicsLoading());
      final topics = await _networkRepository.getGrammarTopics();
      emit(GrammarTopicsLoaded(topics));
    } catch (e) {
      emit(GrammarTopicsError('Failed to load topics: ${e.toString()}'));
    }
  }
}
