import 'package:flutter_test/flutter_test.dart';
import 'package:yazich_ok/data/repositories/mock_network_repository.dart';
import 'package:yazich_ok/data/models/flash_card.dart';

void main() {
  group('MockNetworkRepository', () {
    late MockNetworkRepository repository;

    setUp(() {
      repository = MockNetworkRepository();
    });

    test('getFlashcardGroups returns initial groups', () async {
      final groups = await repository.getFlashcardGroups();

      expect(groups, isNotEmpty);
      expect(groups.any((g) => g.title == 'Travel'), isTrue);
      expect(groups.any((g) => g.title == 'Cafe'), isTrue);
    });

    test('addFlashcardGroup adds new group', () async {
      await repository.addFlashcardGroup('New Group');

      final groups = await repository.getFlashcardGroups();
      expect(groups.any((g) => g.title == 'New Group'), isTrue);
    });

    test('addWord adds word to group', () async {
      final groups = await repository.getFlashcardGroups();
      final travelGroup = groups.firstWhere((g) => g.title == 'Travel');

      const newWord = FlashCard(
        id: 'test-word',
        word: 'test',
        transcription: 'test',
        translation: 'тест',
      );

      await repository.addWord(travelGroup.id, newWord);

      final words = await repository.getWordsForGroup(travelGroup.id);
      expect(words.any((w) => w.word == 'test'), isTrue);
    });

    test('getGrammarTopics returns topics', () async {
      final topics = await repository.getGrammarTopics();

      expect(topics, isNotEmpty);
      expect(topics.any((t) => t.title == 'Articles'), isTrue);
      expect(topics.any((t) => t.title == 'Tenses'), isTrue);
    });

    test('getQuestions returns questions for topic', () async {
      final questions = await repository.getQuestions('t-articles');

      expect(questions, isNotEmpty);
      expect(questions.length, 10);
    });

    test('getAudioRecords returns audio records', () async {
      final records = await repository.getAudioRecords();

      expect(records, isNotEmpty);
    });

    test('getSpeakingTopics returns topics', () async {
      final topics = await repository.getSpeakingTopics();

      expect(topics, isNotEmpty);
      expect(topics.length, greaterThan(0));
    });

    test('assessRecording returns result', () async {
      final result = await repository.assessRecording('audio-blob', 'st-1');

      expect(result.overallScore, greaterThanOrEqualTo(70));
      expect(result.overallScore, lessThanOrEqualTo(95));
      expect(result.topicId, 'st-1');
    });

    test('getArticles returns articles', () async {
      final articles = await repository.getArticles();

      expect(articles, isNotEmpty);
      expect(articles.length, 2);
    });

    test('getArticle returns specific article', () async {
      final article = await repository.getArticle('art-1');

      expect(article.id, 'art-1');
      expect(article.title, contains('Benefits'));
    });

    test('analyzeArticle returns analysis', () async {
      final analysis = await repository.analyzeArticle('art-1');

      expect(analysis.articleId, 'art-1');
      expect(analysis.vocabulary, isNotEmpty);
      expect(analysis.grammarPoints, isNotEmpty);
    });
  });
}
