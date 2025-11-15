import 'package:equatable/equatable.dart';
import 'flash_card.dart';

/// Represents a group of flashcards (e.g., Travel, Cafe, Education)
class WordGroup extends Equatable {
  final String id;
  final String title;
  final List<FlashCard> words;

  const WordGroup({
    required this.id,
    required this.title,
    required this.words,
  });

  factory WordGroup.fromJson(Map<String, dynamic> json) {
    return WordGroup(
      id: json['id'] as String,
      title: json['title'] as String,
      words: (json['words'] as List<dynamic>?)
              ?.map((e) => FlashCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'words': words.map((e) => e.toJson()).toList(),
    };
  }

  WordGroup copyWith({
    String? id,
    String? title,
    List<FlashCard>? words,
  }) {
    return WordGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      words: words ?? this.words,
    );
  }

  int get wordCount => words.length;

  @override
  List<Object?> get props => [id, title, words];
}
