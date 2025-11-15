import 'package:equatable/equatable.dart';

/// Represents a single flashcard with word, transcription, and translation
class FlashCard extends Equatable {
  final String id;
  final String word;
  final String transcription;
  final String translation;

  const FlashCard({
    required this.id,
    required this.word,
    required this.transcription,
    required this.translation,
  });

  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      id: json['id'] as String,
      word: json['word'] as String,
      transcription: json['transcription'] as String? ?? '',
      translation: json['translation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'transcription': transcription,
      'translation': translation,
    };
  }

  FlashCard copyWith({
    String? id,
    String? word,
    String? transcription,
    String? translation,
  }) {
    return FlashCard(
      id: id ?? this.id,
      word: word ?? this.word,
      transcription: transcription ?? this.transcription,
      translation: translation ?? this.translation,
    );
  }

  @override
  List<Object?> get props => [id, word, transcription, translation];
}
