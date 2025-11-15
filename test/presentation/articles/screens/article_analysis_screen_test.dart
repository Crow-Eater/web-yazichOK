import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/presentation/articles/screens/article_analysis_screen.dart';
import 'package:yazich_ok/presentation/articles/cubit/articles_cubit.dart';
import 'package:yazich_ok/presentation/articles/cubit/articles_state.dart';
import 'package:yazich_ok/data/models/article.dart';
import 'package:yazich_ok/data/models/article_analysis.dart';
import 'package:yazich_ok/data/models/vocabulary_item.dart';
import 'package:yazich_ok/data/models/grammar_point.dart';

// Mock class
class MockArticlesCubit extends Mock implements ArticlesCubit {}

void main() {
  late MockArticlesCubit mockCubit;

  setUp(() {
    mockCubit = MockArticlesCubit();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<ArticlesCubit>.value(
        value: mockCubit,
        child: const ArticleAnalysisScreen(articleId: 'art-1'),
      ),
    );
  }

  group('ArticleAnalysisScreen', () {
    const testArticle = Article(
      id: 'art-1',
      title: 'Test Article Title',
      author: 'Test Author',
      publishedDate: '2024-01-01',
      readingTime: 5,
      difficulty: 'intermediate',
      excerpt: 'Test excerpt',
      content: 'Test content',
    );

    final testAnalysis = ArticleAnalysis(
      articleId: 'art-1',
      vocabulary: const [
        VocabularyItem(
          word: 'cognitive',
          definition: 'relating to mental processes',
          difficulty: 'advanced',
        ),
        VocabularyItem(
          word: 'enhance',
          definition: 'to improve or increase',
          difficulty: 'intermediate',
        ),
      ],
      grammarPoints: const [
        GrammarPoint(
          structure: 'Present Perfect',
          example: 'has shown',
          explanation: 'Used for actions with present relevance',
        ),
      ],
      summary: 'This is a test summary of the article.',
    );

    testWidgets('shows processing message when ArticleAnalysisProcessing',
        (WidgetTester tester) async {
      when(() => mockCubit.state)
          .thenReturn(const ArticleAnalysisProcessing(testArticle));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Analyzing Your Article...'), findsOneWidget);
      expect(
        find.text('Please wait while we extract key information'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message and retry button when ArticlesError',
        (WidgetTester tester) async {
      const errorMessage = 'Analysis failed';
      when(() => mockCubit.state)
          .thenReturn(const ArticlesError(errorMessage));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Analysis Failed'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    });

    testWidgets('calls analyzeArticle when retry button is tapped',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const ArticlesError('Test error'));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.analyzeArticle('art-1')).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pump();

      verify(() => mockCubit.analyzeArticle('art-1')).called(1);
    });

    testWidgets('displays analysis results when ArticleAnalysisCompleted',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(ArticleAnalysisCompleted(
        article: testArticle,
        analysis: testAnalysis,
      ));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Analysis Results'), findsOneWidget);
      expect(find.text('Test Article Title'), findsOneWidget);

      // Check summary section
      expect(find.text('Article Summary'), findsOneWidget);
      expect(find.text('This is a test summary of the article.'), findsOneWidget);
    });

    testWidgets('displays vocabulary items correctly',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(ArticleAnalysisCompleted(
        article: testArticle,
        analysis: testAnalysis,
      ));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Vocabulary Analysis'), findsOneWidget);
      expect(find.text('cognitive'), findsOneWidget);
      expect(find.text('relating to mental processes'), findsOneWidget);
      expect(find.text('ADVANCED'), findsOneWidget);
      expect(find.text('enhance'), findsOneWidget);
      expect(find.text('to improve or increase'), findsOneWidget);
      expect(find.text('INTERMEDIATE'), findsOneWidget);
    });

    testWidgets('displays grammar points correctly',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(ArticleAnalysisCompleted(
        article: testArticle,
        analysis: testAnalysis,
      ));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Grammar Points'), findsOneWidget);
      expect(find.text('Present Perfect'), findsOneWidget);
      expect(find.text('has shown'), findsOneWidget);
      expect(find.text('Used for actions with present relevance'), findsOneWidget);
    });

    testWidgets('has back to article button', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(ArticleAnalysisCompleted(
        article: testArticle,
        analysis: testAnalysis,
      ));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(OutlinedButton, 'Back to Article'),
        findsOneWidget,
      );
    });

    testWidgets('has correct app bar title', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const ArticlesInitial());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(AppBar, 'Article Analysis'), findsOneWidget);
    });
  });
}
