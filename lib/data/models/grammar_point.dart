import 'package:equatable/equatable.dart';

/// Represents a grammar point identified in an article
class GrammarPoint extends Equatable {
  final String structure;
  final String example;
  final String explanation;

  const GrammarPoint({
    required this.structure,
    required this.example,
    required this.explanation,
  });

  factory GrammarPoint.fromJson(Map<String, dynamic> json) {
    return GrammarPoint(
      structure: json['structure'] as String,
      example: json['example'] as String,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'structure': structure,
      'example': example,
      'explanation': explanation,
    };
  }

  @override
  List<Object?> get props => [structure, example, explanation];
}
