import 'package:equatable/equatable.dart';

/// Represents an audio record for listening practice
class AudioRecord extends Equatable {
  final String id;
  final String title;
  final String asset;
  final String duration;
  final String? difficulty;

  const AudioRecord({
    required this.id,
    required this.title,
    required this.asset,
    required this.duration,
    this.difficulty,
  });

  factory AudioRecord.fromJson(Map<String, dynamic> json) {
    return AudioRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      asset: json['asset'] as String,
      duration: json['duration'] as String,
      difficulty: json['difficulty'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'asset': asset,
      'duration': duration,
      'difficulty': difficulty,
    };
  }

  @override
  List<Object?> get props => [id, title, asset, duration, difficulty];
}
