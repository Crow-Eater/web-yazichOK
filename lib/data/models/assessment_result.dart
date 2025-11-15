import 'package:equatable/equatable.dart';

/// Represents the result of a speaking assessment
class AssessmentResult extends Equatable {
  final String id;
  final String topicId;
  final int overallScore; // 0-100
  final int pronunciationScore;
  final int fluencyScore;
  final int accuracyScore;
  final String feedback;
  final DateTime timestamp;

  const AssessmentResult({
    required this.id,
    required this.topicId,
    required this.overallScore,
    required this.pronunciationScore,
    required this.fluencyScore,
    required this.accuracyScore,
    required this.feedback,
    required this.timestamp,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      overallScore: json['overallScore'] as int,
      pronunciationScore: json['pronunciationScore'] as int,
      fluencyScore: json['fluencyScore'] as int,
      accuracyScore: json['accuracyScore'] as int,
      feedback: json['feedback'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'overallScore': overallScore,
      'pronunciationScore': pronunciationScore,
      'fluencyScore': fluencyScore,
      'accuracyScore': accuracyScore,
      'feedback': feedback,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        topicId,
        overallScore,
        pronunciationScore,
        fluencyScore,
        accuracyScore,
        feedback,
        timestamp,
      ];
}
