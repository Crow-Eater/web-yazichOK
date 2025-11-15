import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/presentation/articles/screens/articles_preview_screen.dart';
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
    return MaterialApp(
      home: BlocProvider<ArticlesCubit>.value(
        value: mockCubit,
        child: const ArticlesPreviewScreen(),
      ),
    );
  }

  group('ArticlesPreviewScreen', () {
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

    testWidgets('shows loading indicator when ArticlesLoading',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const ArticlesLoading());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message and retry button when ArticlesError',
        (WidgetTester tester) async {
      const errorMessage = 'Test error message';
      when(() => mockCubit.state)
          .thenReturn(const ArticlesError(errorMessage));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    });

    testWidgets('calls loadArticles when retry button is tapped',
        (WidgetTester tester) async {
      when(() => mockCubit.state)
          .thenReturn(const ArticlesError('Test error'));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.loadArticles()).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pump();

      verify(() => mockCubit.loadArticles()).called(1);
    });

    testWidgets('shows empty state when no articles available',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const ArticlesLoaded([]));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('No articles available'), findsOneWidget);
      expect(find.text('Check back later for new content'), findsOneWidget);
    });

    testWidgets('shows list of articles when ArticlesLoaded',
        (WidgetTester tester) async {
      when(() => mockCubit.state)
          .thenReturn(const ArticlesLoaded([testArticle1, testArticle2]));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Article 1'), findsOneWidget);
      expect(find.text('Test Article 2'), findsOneWidget);
      expect(find.text('Test excerpt 1'), findsOneWidget);
      expect(find.text('Test excerpt 2'), findsOneWidget);
    });

    testWidgets('displays article metadata correctly',
        (WidgetTester tester) async {
      when(() => mockCubit.state)
          .thenReturn(const ArticlesLoaded([testArticle1]));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Author'), findsOneWidget);
      expect(find.text('2024-01-01'), findsOneWidget);
      expect(find.text('5 min read'), findsOneWidget);
      expect(find.text('INTERMEDIATE'), findsOneWidget);
    });

    testWidgets('has correct app bar title', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const ArticlesInitial());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(AppBar, 'Articles'), findsOneWidget);
    });
  });
}
