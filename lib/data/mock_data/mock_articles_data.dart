import '../models/article.dart';
import '../models/article_analysis.dart';
import '../models/vocabulary_item.dart';
import '../models/grammar_point.dart';

/// Mock articles from plan.md
final List<Article> mockArticles = [
  const Article(
    id: 'art-1',
    title: 'The Benefits of Learning a New Language',
    author: 'Language Learning Team',
    publishedDate: '2024-01-15',
    readingTime: 5,
    difficulty: 'intermediate',
    excerpt:
        'Learning a new language opens doors to new cultures, improves cognitive function, and enhances career opportunities...',
    content: '''
Learning a new language is one of the most rewarding investments you can make in yourself. Not only does it open doors to new cultures and ways of thinking, but it also has numerous cognitive and professional benefits.

## Cognitive Benefits

Research has shown that learning a new language improves brain function. It enhances memory, problem-solving skills, and critical thinking abilities. Bilingual individuals often demonstrate better multitasking skills and improved concentration.

## Cultural Understanding

When you learn a language, you gain access to a new culture. You can read literature in its original form, understand films without subtitles, and communicate with native speakers in a meaningful way. This cultural immersion enriches your worldview and fosters empathy.

## Career Opportunities

In today's globalized world, multilingual professionals are in high demand. Companies value employees who can communicate with international clients and navigate different cultural contexts. Language skills can significantly enhance your career prospects and earning potential.

## Personal Growth

The process of learning a language teaches patience, discipline, and resilience. It challenges you to step out of your comfort zone and embrace mistakes as part of the learning journey. These skills transfer to other areas of life.

## Getting Started

The best time to start learning a language is now. With modern technology, language learning apps, online tutors, and immersive resources are more accessible than ever. Set realistic goals, practice consistently, and enjoy the journey of linguistic discovery.
''',
  ),
  const Article(
    id: 'art-2',
    title: 'Effective Study Techniques for Language Learners',
    author: 'Education Expert',
    publishedDate: '2024-01-20',
    readingTime: 7,
    difficulty: 'advanced',
    excerpt: 'Discover proven methods to accelerate your language learning journey...',
    content: '''
Mastering a new language requires more than just memorization—it demands strategic study techniques that align with how our brains process and retain information.

## Spaced Repetition

One of the most effective techniques is spaced repetition. Instead of cramming, review material at increasing intervals. This method leverages the psychological spacing effect, where information reviewed over time is better retained than information studied in a single session.

## Active Recall

Rather than passively reading or listening, actively test yourself. Flashcards, practice tests, and speaking exercises force your brain to retrieve information, strengthening neural pathways and improving long-term retention.

## Immersion

Surround yourself with the language. Watch films, listen to podcasts, read books, and if possible, travel to countries where the language is spoken. Immersion accelerates learning by providing context and real-world application.

## Language Exchange

Practice with native speakers through language exchange programs. This provides authentic conversation practice, immediate feedback, and cultural insights that textbooks cannot offer.

## Consistency Over Intensity

Regular, short study sessions are more effective than occasional marathon sessions. Even 15-30 minutes daily can yield significant progress over time. Establish a routine and stick to it.

## Multimodal Learning

Engage multiple senses: read aloud, write by hand, listen to audio, and watch videos. Different modalities reinforce learning and cater to various learning styles.

## Conclusion

Effective language learning is a marathon, not a sprint. By employing these evidence-based techniques and maintaining consistent effort, you'll make steady progress toward fluency.
''',
  ),
];

/// Mock article analyses
final Map<String, ArticleAnalysis> mockArticleAnalyses = {
  'art-1': ArticleAnalysis(
    articleId: 'art-1',
    vocabulary: const [
      VocabularyItem(
        word: 'cognitive',
        definition: 'relating to mental processes of perception, memory, judgment',
        difficulty: 'advanced',
      ),
      VocabularyItem(
        word: 'enhance',
        definition: 'to improve or increase in value, quality, or attractiveness',
        difficulty: 'intermediate',
      ),
      VocabularyItem(
        word: 'bilingual',
        definition: 'able to speak two languages fluently',
        difficulty: 'intermediate',
      ),
      VocabularyItem(
        word: 'immersion',
        definition: 'deep mental involvement in something',
        difficulty: 'advanced',
      ),
      VocabularyItem(
        word: 'resilience',
        definition: 'the capacity to recover quickly from difficulties',
        difficulty: 'advanced',
      ),
    ],
    grammarPoints: const [
      GrammarPoint(
        structure: 'Present Perfect',
        example: 'has shown',
        explanation:
            'Used for actions that started in the past and have present relevance',
      ),
      GrammarPoint(
        structure: 'Modal Verbs',
        example: 'can significantly enhance',
        explanation: 'Express ability, permission, or possibility',
      ),
      GrammarPoint(
        structure: 'Comparative Adjectives',
        example: 'better multitasking skills',
        explanation: 'Used to compare two things',
      ),
    ],
    summary:
        'The article discusses how learning languages improves brain function, cultural understanding, and career prospects. It emphasizes cognitive benefits like improved memory and problem-solving, cultural enrichment through authentic engagement, and enhanced professional opportunities in a globalized world.',
  ),
  'art-2': ArticleAnalysis(
    articleId: 'art-2',
    vocabulary: const [
      VocabularyItem(
        word: 'strategic',
        definition: 'relating to the identification of long-term aims and methods',
        difficulty: 'intermediate',
      ),
      VocabularyItem(
        word: 'leverage',
        definition: 'use something to maximum advantage',
        difficulty: 'advanced',
      ),
      VocabularyItem(
        word: 'retention',
        definition: 'the continued possession or use of something',
        difficulty: 'advanced',
      ),
      VocabularyItem(
        word: 'multimodal',
        definition: 'involving several different modes, methods, or types',
        difficulty: 'advanced',
      ),
    ],
    grammarPoints: const [
      GrammarPoint(
        structure: 'Gerunds',
        example: 'learning requires',
        explanation: 'Verb forms ending in -ing used as nouns',
      ),
      GrammarPoint(
        structure: 'Comparative Structures',
        example: 'more effective than',
        explanation: 'Used to compare two actions or things',
      ),
    ],
    summary:
        'The article presents evidence-based study techniques including spaced repetition, active recall, immersion, language exchange, and multimodal learning. It emphasizes consistency over intensity and strategic approaches to language acquisition.',
  ),
};
