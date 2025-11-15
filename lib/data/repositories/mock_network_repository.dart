import 'dart:math';
import '../../domain/repositories/network_repository.dart';
import '../models/word_group.dart';
import '../models/flash_card.dart';
import '../models/grammar_topic.dart';
import '../models/question.dart';
import '../models/audio_record.dart';
import '../models/speaking_topic.dart';
import '../models/assessment_result.dart';
import '../models/article.dart';
import '../models/article_analysis.dart';
import '../mock_data/mock_flashcard_data.dart';
import '../mock_data/mock_grammar_data.dart';
import '../mock_data/mock_audio_data.dart';
import '../mock_data/mock_speaking_data.dart';
import '../models/article_analysis.dart' show ArticleAnalysis;
import '../mock_data/mock_articles_data.dart';

/// Mock implementation of NetworkRepository using in-memory data
class MockNetworkRepository implements NetworkRepository {
  // In-memory storage for flashcards (mutable copy)
  final List<WordGroup> _groups = List.from(mockFlashcardGroups);

  // In-memory storage for assessment history
  final List<AssessmentResult> _assessmentHistory = [];

  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<List<WordGroup>> getFlashcardGroups() async {
    await _simulateDelay();
    return List.from(_groups);
  }

  @override
  Future<void> addFlashcardGroup(String name) async {
    await _simulateDelay();
    final newGroup = WordGroup(
      id: 'g-${DateTime.now().millisecondsSinceEpoch}',
      title: name,
      words: const [],
    );
    _groups.add(newGroup);
  }

  @override
  Future<void> addWord(String groupId, FlashCard word) async {
    await _simulateDelay();
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1) {
      final group = _groups[groupIndex];
      final updatedWords = List<FlashCard>.from(group.words)..add(word);
      _groups[groupIndex] = group.copyWith(words: updatedWords);
    }
  }

  @override
  Future<List<FlashCard>> getWordsForGroup(String groupId) async {
    await _simulateDelay();
    final group = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => const WordGroup(id: '', title: '', words: []),
    );
    return group.words;
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await _simulateDelay();
    _groups.removeWhere((g) => g.id == groupId);
  }

  @override
  Future<void> deleteWord(String wordId) async {
    await _simulateDelay();
    for (var i = 0; i < _groups.length; i++) {
      final group = _groups[i];
      final updatedWords = group.words.where((w) => w.id != wordId).toList();
      if (updatedWords.length != group.words.length) {
        _groups[i] = group.copyWith(words: updatedWords);
        break;
      }
    }
  }

  @override
  Future<List<GrammarTopic>> getGrammarTopics() async {
    await _simulateDelay();
    return List.from(mockGrammarTopics);
  }

  @override
  Future<List<Question>> getQuestions(String topicId) async {
    await _simulateDelay();
    return List.from(mockQuestions[topicId] ?? []);
  }

  @override
  Future<List<AudioRecord>> getAudioRecords() async {
    await _simulateDelay();
    return List.from(mockAudioRecords);
  }

  @override
  Future<List<SpeakingTopic>> getSpeakingTopics() async {
    await _simulateDelay();
    return List.from(mockSpeakingTopics);
  }

  @override
  Future<AssessmentResult> assessRecording(String audioBlob, String topicId) async {
    await _simulateDelay();

    // Generate mock assessment scores
    final random = Random();
    final result = AssessmentResult(
      id: 'ar-${DateTime.now().millisecondsSinceEpoch}',
      topicId: topicId,
      overallScore: 70 + random.nextInt(25), // 70-95
      pronunciationScore: 65 + random.nextInt(30), // 65-95
      fluencyScore: 70 + random.nextInt(25), // 70-95
      accuracyScore: 75 + random.nextInt(20), // 75-95
      feedback: 'Good effort! Your pronunciation is clear, and your fluency shows improvement. '
          'Consider working on vocabulary range and grammatical accuracy.',
      timestamp: DateTime.now(),
    );

    _assessmentHistory.add(result);
    return result;
  }

  @override
  Future<List<AssessmentResult>> getAssessmentHistory() async {
    await _simulateDelay();
    return List.from(_assessmentHistory.reversed);
  }

  @override
  Future<List<Article>> getArticles() async {
    await _simulateDelay();
    return List.from(mockArticles);
  }

  @override
  Future<Article> getArticle(String id) async {
    await _simulateDelay();
    return mockArticles.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('Article not found'),
    );
  }

  @override
  Future<ArticleAnalysis> analyzeArticle(String id) async {
    await _simulateDelay();

    final analysis = mockArticleAnalyses[id];
    if (analysis != null) {
      return analysis;
    }

    throw Exception('Analysis not available for this article');
  }
}
