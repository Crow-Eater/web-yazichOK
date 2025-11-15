import 'package:equatable/equatable.dart';

/// Represents a grammar topic (e.g., Articles, Tenses, Prepositions)
class GrammarTopic extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int questionCount;

  const GrammarTopic({
    required this.id,
    required this.title,
    this.description,
    required this.questionCount,
  });

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    return GrammarTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      questionCount: json['questions'] as int? ?? json['questionCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questionCount,
    };
  }

  @override
  List<Object?> get props => [id, title, description, questionCount];
}
