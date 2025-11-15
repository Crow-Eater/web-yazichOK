import '../../data/models/word_group.dart';
import '../../data/models/flash_card.dart';
import '../../data/models/grammar_topic.dart';
import '../../data/models/question.dart';
import '../../data/models/audio_record.dart';
import '../../data/models/speaking_topic.dart';
import '../../data/models/assessment_result.dart';
import '../../data/models/article.dart';
import '../../data/models/article_analysis.dart';

/// Interface for network operations
/// Mock implementation uses local data, real implementation will use HTTP
abstract class NetworkRepository {
  // FlashCards
  Future<List<WordGroup>> getFlashcardGroups();
  Future<void> addFlashcardGroup(String name);
  Future<void> addWord(String groupId, FlashCard word);
  Future<List<FlashCard>> getWordsForGroup(String groupId);
  Future<void> deleteGroup(String groupId);
  Future<void> deleteWord(String wordId);

  // Grammar / Tests
  Future<List<GrammarTopic>> getGrammarTopics();
  Future<List<Question>> getQuestions(String topicId);

  // Listening
  Future<List<AudioRecord>> getAudioRecords();

  // Speaking
  Future<List<SpeakingTopic>> getSpeakingTopics();
  Future<AssessmentResult> assessRecording(String audioBlob, String topicId);
  Future<List<AssessmentResult>> getAssessmentHistory();

  // Articles
  Future<List<Article>> getArticles();
  Future<Article> getArticle(String id);
  Future<ArticleAnalysis> analyzeArticle(String id);
}
