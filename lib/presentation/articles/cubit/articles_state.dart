import 'package:equatable/equatable.dart';
import '../../../data/models/article.dart';
import '../../../data/models/article_analysis.dart';

/// Base state for Articles feature
abstract class ArticlesState extends Equatable {
  const ArticlesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ArticlesInitial extends ArticlesState {
  const ArticlesInitial();
}

/// Loading articles list
class ArticlesLoading extends ArticlesState {
  const ArticlesLoading();
}

/// Articles list loaded successfully
class ArticlesLoaded extends ArticlesState {
  final List<Article> articles;

  const ArticlesLoaded(this.articles);

  @override
  List<Object?> get props => [articles];
}

/// Loading a single article
class ArticleLoading extends ArticlesState {
  const ArticleLoading();
}

/// Single article loaded successfully
class ArticleLoaded extends ArticlesState {
  final Article article;

  const ArticleLoaded(this.article);

  @override
  List<Object?> get props => [article];
}

/// Processing article analysis
class ArticleAnalysisProcessing extends ArticlesState {
  final Article article;

  const ArticleAnalysisProcessing(this.article);

  @override
  List<Object?> get props => [article];
}

/// Article analysis completed
class ArticleAnalysisCompleted extends ArticlesState {
  final Article article;
  final ArticleAnalysis analysis;

  const ArticleAnalysisCompleted({
    required this.article,
    required this.analysis,
  });

  @override
  List<Object?> get props => [article, analysis];
}

/// Error state
class ArticlesError extends ArticlesState {
  final String message;

  const ArticlesError(this.message);

  @override
  List<Object?> get props => [message];
}
