import 'package:equatable/equatable.dart';

/// Represents a speaking practice topic
class SpeakingTopic extends Equatable {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int timeLimit; // in seconds

  const SpeakingTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.timeLimit,
  });

  factory SpeakingTopic.fromJson(Map<String, dynamic> json) {
    return SpeakingTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String? ?? 'intermediate',
      timeLimit: json['timeLimit'] as int? ?? 120,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'timeLimit': timeLimit,
    };
  }

  @override
  List<Object?> get props => [id, title, description, difficulty, timeLimit];
}
