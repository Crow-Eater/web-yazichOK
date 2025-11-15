import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/network_repository.dart';
import 'articles_state.dart';

/// Cubit for managing Articles feature state
class ArticlesCubit extends Cubit<ArticlesState> {
  final NetworkRepository _networkRepository;

  ArticlesCubit(this._networkRepository) : super(const ArticlesInitial());

  /// Load all articles
  Future<void> loadArticles() async {
    try {
      emit(const ArticlesLoading());
      final articles = await _networkRepository.getArticles();
      emit(ArticlesLoaded(articles));
    } catch (e) {
      emit(ArticlesError('Failed to load articles: ${e.toString()}'));
    }
  }

  /// Load a single article by ID
  Future<void> loadArticle(String id) async {
    try {
      emit(const ArticleLoading());
      final article = await _networkRepository.getArticle(id);
      emit(ArticleLoaded(article));
    } catch (e) {
      emit(ArticlesError('Failed to load article: ${e.toString()}'));
    }
  }

  /// Analyze an article (get vocabulary, grammar points, summary)
  Future<void> analyzeArticle(String id) async {
    try {
      // First load the article
      final article = await _networkRepository.getArticle(id);

      // Show processing state
      emit(ArticleAnalysisProcessing(article));

      // Get the analysis
      final analysis = await _networkRepository.analyzeArticle(id);

      // Emit completed state
      emit(ArticleAnalysisCompleted(
        article: article,
        analysis: analysis,
      ));
    } catch (e) {
      emit(ArticlesError('Failed to analyze article: ${e.toString()}'));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(const ArticlesInitial());
  }
}
