import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:yazich_ok/presentation/articles/cubit/articles_cubit.dart';
import 'package:yazich_ok/presentation/articles/cubit/articles_state.dart';
import 'package:yazich_ok/domain/repositories/network_repository.dart';
import 'package:yazich_ok/data/models/article.dart';
import 'package:yazich_ok/data/models/article_analysis.dart';
import 'package:yazich_ok/data/models/vocabulary_item.dart';
import 'package:yazich_ok/data/models/grammar_point.dart';

// Mock classes
class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  late ArticlesCubit cubit;
  late MockNetworkRepository mockRepository;

  setUp(() {
    mockRepository = MockNetworkRepository();
    cubit = ArticlesCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('ArticlesCubit', () {
    const testArticle1 = Article(
      id: 'art-1',
      title: 'Test Article 1',
      author: 'Test Author',
      publishedDate: '2024-01-01',
      readingTime: 5,
      difficulty: 'intermediate',
      excerpt: 'Test excerpt 1',
      content: 'Test content 1',
    );

    const testArticle2 = Article(
      id: 'art-2',
      title: 'Test Article 2',
      author: 'Test Author 2',
      publishedDate: '2024-01-02',
      readingTime: 7,
      difficulty: 'advanced',
      excerpt: 'Test excerpt 2',
      content: 'Test content 2',
    );

    final testAnalysis = ArticleAnalysis(
      articleId: 'art-1',
      vocabulary: const [
        VocabularyItem(
          word: 'test',
          definition: 'a test word',
          difficulty: 'intermediate',
        ),
      ],
      grammarPoints: const [
        GrammarPoint(
          structure: 'Present Perfect',
          example: 'has tested',
          explanation: 'Used for actions with present relevance',
        ),
      ],
      summary: 'This is a test summary',
    );

    test('initial state is ArticlesInitial', () {
      expect(cubit.state, equals(const ArticlesInitial()));
    });

    group('loadArticles', () {
      blocTest<ArticlesCubit, ArticlesState>(
        'emits [ArticlesLoading, ArticlesLoaded] when successful',
        build: () {
          when(() => mockRepository.getArticles())
              .thenAnswer((_) async => [testArticle1, testArticle2]);
          return cubit;
        },
        act: (cubit) => cubit.loadArticles(),
        expect: () => [
          const ArticlesLoading(),
          ArticlesLoaded(const [testArticle1, testArticle2]),
        ],
        verify: (_) {
          verify(() => mockRepository.getArticles()).called(1);
        },
      );

      blocTest<ArticlesCubit, ArticlesState>(
        'emits [ArticlesLoading, ArticlesError] when fails',
        build: () {
          when(() => mockRepository.getArticles())
              .thenThrow(Exception('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.loadArticles(),
        expect: () => [
          const ArticlesLoading(),
          const ArticlesError('Failed to load articles: Exception: Network error'),
        ],
      );

      blocTest<ArticlesCubit, ArticlesState>(
        'emits empty list when no articles available',
        build: () {
          when(() => mockRepository.getArticles()).thenAnswer((_) async => []);
          return cubit;
        },
        act: (cubit) => cubit.loadArticles(),
        expect: () => [
          const ArticlesLoading(),
          const ArticlesLoaded([]),
        ],
      );
    });

    group('loadArticle', () {
      blocTest<ArticlesCubit, ArticlesState>(
        'emits [ArticleLoading, ArticleLoaded] when successful',
        build: () {
          when(() => mockRepository.getArticle('art-1'))
              .thenAnswer((_) async => testArticle1);
          return cubit;
        },
        act: (cubit) => cubit.loadArticle('art-1'),
        expect: () => [
          const ArticleLoading(),
          const ArticleLoaded(testArticle1),
        ],
        verify: (_) {
          verify(() => mockRepository.getArticle('art-1')).called(1);
        },
      );

      blocTest<ArticlesCubit, ArticlesState>(
        'emits [ArticleLoading, ArticlesError] when article not found',
        build: () {
          when(() => mockRepository.getArticle('invalid-id'))
              .thenThrow(Exception('Article not found'));
          return cubit;
        },
        act: (cubit) => cubit.loadArticle('invalid-id'),
        expect: () => [
          const ArticleLoading(),
          const ArticlesError('Failed to load article: Exception: Article not found'),
        ],
      );
    });

    group('analyzeArticle', () {
      blocTest<ArticlesCubit, ArticlesState>(
        'emits [ArticleAnalysisProcessing, ArticleAnalysisCompleted] when successful',
        build: () {
          when(() => mockRepository.getArticle('art-1'))
              .thenAnswer((_) async => testArticle1);
          when(() => mockRepository.analyzeArticle('art-1'))
              .thenAnswer((_) async => testAnalysis);
          return cubit;
        },
        act: (cubit) => cubit.analyzeArticle('art-1'),
        expect: () => [
          const ArticleAnalysisProcessing(testArticle1),
          ArticleAnalysisCompleted(
            article: testArticle1,
            analysis: testAnalysis,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getArticle('art-1')).called(1);
          verify(() => mockRepository.analyzeArticle('art-1')).called(1);
        },
      );

      blocTest<ArticlesCubit, ArticlesState>(
        'emits [ArticlesError] when article not found',
        build: () {
          when(() => mockRepository.getArticle('invalid-id'))
              .thenThrow(Exception('Article not found'));
          return cubit;
        },
        act: (cubit) => cubit.analyzeArticle('invalid-id'),
        expect: () => [
          const ArticlesError('Failed to analyze article: Exception: Article not found'),
        ],
      );

      blocTest<ArticlesCubit, ArticlesState>(
        'emits [ArticleAnalysisProcessing, ArticlesError] when analysis fails',
        build: () {
          when(() => mockRepository.getArticle('art-1'))
              .thenAnswer((_) async => testArticle1);
          when(() => mockRepository.analyzeArticle('art-1'))
              .thenThrow(Exception('Analysis not available'));
          return cubit;
        },
        act: (cubit) => cubit.analyzeArticle('art-1'),
        expect: () => [
          const ArticleAnalysisProcessing(testArticle1),
          const ArticlesError('Failed to analyze article: Exception: Analysis not available'),
        ],
      );
    });

    group('reset', () {
      blocTest<ArticlesCubit, ArticlesState>(
        'resets to ArticlesInitial',
        build: () => cubit,
        seed: () => const ArticlesLoaded([testArticle1]),
        act: (cubit) => cubit.reset(),
        expect: () => [const ArticlesInitial()],
      );
    });
  });
}
