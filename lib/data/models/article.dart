import 'package:equatable/equatable.dart';

/// Represents an article for reading practice
class Article extends Equatable {
  final String id;
  final String title;
  final String author;
  final String publishedDate;
  final int readingTime; // in minutes
  final String difficulty;
  final String excerpt;
  final String content;

  const Article({
    required this.id,
    required this.title,
    required this.author,
    required this.publishedDate,
    required this.readingTime,
    required this.difficulty,
    required this.excerpt,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      publishedDate: json['publishedDate'] as String,
      readingTime: json['readingTime'] as int,
      difficulty: json['difficulty'] as String,
      excerpt: json['excerpt'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publishedDate': publishedDate,
      'readingTime': readingTime,
      'difficulty': difficulty,
      'excerpt': excerpt,
      'content': content,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        publishedDate,
        readingTime,
        difficulty,
        excerpt,
        content,
      ];
}
