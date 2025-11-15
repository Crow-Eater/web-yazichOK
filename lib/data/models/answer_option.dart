import 'package:equatable/equatable.dart';

/// Represents an answer option for a test question
class AnswerOption extends Equatable {
  final String text;
  final bool isCorrect;

  const AnswerOption({
    required this.text,
    required this.isCorrect,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }

  @override
  List<Object?> get props => [text, isCorrect];
}
