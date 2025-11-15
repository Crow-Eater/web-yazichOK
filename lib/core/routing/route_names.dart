/// Route path constants for the application
class Routes {
  Routes._();

  // Main
  static const String main = '/';

  // Auth
  static const String signIn = '/signin';
  static const String signUp = '/signup';

  // FlashCards
  static const String flashcards = '/flashcards';
  static const String addWord = '/flashcards/add-word';
  static const String addGroup = '/flashcards/add-group';
  static const String memoriseWords = '/flashcards/group/:groupId';

  // Learn
  static const String learn = '/learn';
  static const String grammarTopics = '/learn/grammar-topics';
  static const String test = '/learn/test/:topicId';
  static const String listening = '/learn/listening';

  // Speaking
  static const String speakingTopics = '/speaking/topics';
  static const String recording = '/speaking/topics/recording';
  static const String assessment = '/speaking/topics/assessment';
  static const String speakingResults = '/speaking/results';

  // Articles
  static const String articles = '/articles';
  static const String article = '/articles/:articleId';
  static const String articleAnalysis = '/articles/:articleId/analysis';

  /// Helper methods to build routes with parameters
  static String memoriseWordsPath(String groupId) => '/flashcards/group/$groupId';
  static String testPath(String topicId) => '/learn/test/$topicId';
  static String articlePath(String articleId) => '/articles/$articleId';
  static String articleAnalysisPath(String articleId) => '/articles/$articleId/analysis';
}
