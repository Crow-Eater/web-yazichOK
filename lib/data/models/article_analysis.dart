import 'package:equatable/equatable.dart';
import 'vocabulary_item.dart';
import 'grammar_point.dart';

/// Represents the analysis of an article
class ArticleAnalysis extends Equatable {
  final String articleId;
  final List<VocabularyItem> vocabulary;
  final List<GrammarPoint> grammarPoints;
  final String summary;

  const ArticleAnalysis({
    required this.articleId,
    required this.vocabulary,
    required this.grammarPoints,
    required this.summary,
  });

  factory ArticleAnalysis.fromJson(Map<String, dynamic> json) {
    return ArticleAnalysis(
      articleId: json['articleId'] as String,
      vocabulary: (json['vocabulary'] as List<dynamic>)
          .map((e) => VocabularyItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      grammarPoints: (json['grammarPoints'] as List<dynamic>)
          .map((e) => GrammarPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articleId': articleId,
      'vocabulary': vocabulary.map((e) => e.toJson()).toList(),
      'grammarPoints': grammarPoints.map((e) => e.toJson()).toList(),
      'summary': summary,
    };
  }

  @override
  List<Object?> get props => [articleId, vocabulary, grammarPoints, summary];
}
