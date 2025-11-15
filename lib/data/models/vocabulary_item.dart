import 'package:equatable/equatable.dart';

/// Represents a vocabulary item extracted from an article
class VocabularyItem extends Equatable {
  final String word;
  final String definition;
  final String difficulty;

  const VocabularyItem({
    required this.word,
    required this.definition,
    required this.difficulty,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] as String,
      definition: json['definition'] as String,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'definition': definition,
      'difficulty': difficulty,
    };
  }

  @override
  List<Object?> get props => [word, definition, difficulty];
}
