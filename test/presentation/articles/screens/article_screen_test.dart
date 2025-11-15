import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/presentation/articles/screens/article_screen.dart';
import 'package:yazich_ok/presentation/articles/cubit/articles_cubit.dart';
import 'package:yazich_ok/presentation/articles/cubit/articles_state.dart';
import 'package:yazich_ok/data/models/article.dart';

// Mock class
class MockArticlesCubit extends Mock implements ArticlesCubit {}

void main() {
  late MockArticlesCubit mockCubit;

  setUp(() {
    mockCubit = MockArticlesCubit();
  });

  Widget createTestWidget() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<ArticlesCubit>.value(
            value: mockCubit,
            child: const ArticleScreen(articleId: 'art-1'),
          ),
        ),
        GoRoute(
          path: '/articles/:id/analysis',
          builder: (context, state) => const Scaffold(body: Text('Analysis')),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('ArticleScreen', () {
    const testArticle = Article(
      id: 'art-1',
      title: 'Test Article Title',
      author: 'Test Author',
      publishedDate: '2024-01-01',
      readingTime: 5,
      difficulty: 'intermediate',
      excerpt: 'Test excerpt',
      content: '''
This is a test article.

## Section 1

This is the first section.

## Section 2

This is the second section.
''',
    );

    testWidgets('shows loading indicator when ArticleLoading',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const ArticleLoading());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message and retry button when ArticlesError',
        (WidgetTester tester) async {
      const errorMessage = 'Failed to load article';
      when(() => mockCubit.state)
          .thenReturn(const ArticlesError(errorMessage));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Failed to load article'), findsAtLeastNWidgets(1));
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    });

    testWidgets('calls loadArticle when retry button is tapped',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const ArticlesError('Test error'));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.loadArticle('art-1')).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pump();

      verify(() => mockCubit.loadArticle('art-1')).called(1);
    });

    testWidgets('displays article content when ArticleLoaded',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const ArticleLoaded(testArticle));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Article Title'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
      expect(find.text('2024-01-01'), findsOneWidget);
      expect(find.text('INTERMEDIATE'), findsOneWidget);
    });

    testWidgets('displays reading time badge', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const ArticleLoaded(testArticle));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('5 min'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('displays Analyze Article button',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const ArticleLoaded(testArticle));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(
        find.widgetWithText(ElevatedButton, 'Analyze Article'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
    });

    testWidgets('has back button in app bar', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const ArticleLoaded(testArticle));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
