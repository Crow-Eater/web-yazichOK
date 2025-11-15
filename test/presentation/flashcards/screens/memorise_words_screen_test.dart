import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_yazichok/data/models/flash_card.dart';
import 'package:web_yazichok/presentation/flashcards/cubit/memorise_cubit.dart';
import 'package:web_yazichok/presentation/flashcards/cubit/memorise_state.dart';
import 'package:web_yazichok/presentation/flashcards/screens/memorise_words_screen.dart';

class MockMemoriseCubit extends Mock implements MemoriseCubit {}

void main() {
  late MockMemoriseCubit mockCubit;

  setUp(() {
    mockCubit = MockMemoriseCubit();
  });

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<MemoriseCubit>.value(
        value: mockCubit,
        child: child,
      ),
    );
  }

  final testWord = FlashCard(
    id: 'w1',
    word: 'luggage',
    transcription: 'ˈlʌɡ.ɪdʒ',
    translation: 'багаж',
  );

  group('MemoriseWordsScreen', () {
    testWidgets('shows loading indicator when state is MemoriseLoading',
        (tester) async {
      when(() => mockCubit.state).thenReturn(const MemoriseLoading());
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const MemoriseLoading()));

      await tester.pumpWidget(
        makeTestableWidget(const MemoriseWordsScreen(groupId: '1')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when state is MemoriseError',
        (tester) async {
      const errorMessage = 'Failed to load words';
      when(() => mockCubit.state)
          .thenReturn(const MemoriseError(errorMessage));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const MemoriseError(errorMessage)));

      await tester.pumpWidget(
        makeTestableWidget(const MemoriseWordsScreen(groupId: '1')),
      );

      expect(find.text('Error'), findsOneWidget);
      expect(find.textContaining(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows empty state when group has no words', (tester) async {
      when(() => mockCubit.state).thenReturn(const MemoriseEmpty());
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const MemoriseEmpty()));

      await tester.pumpWidget(
        makeTestableWidget(const MemoriseWordsScreen(groupId: '1')),
      );

      expect(find.text('No Words in This Group'), findsOneWidget);
      expect(find.text('Add some words to start practicing'), findsOneWidget);
      expect(find.text('Add Words'), findsOneWidget);
    });

    testWidgets('shows flashcard when state is MemoriseInProgress',
        (tester) async {
      final state = MemoriseInProgress(
        currentWord: testWord,
        currentIndex: 0,
        totalWords: 1,
        knownCount: 0,
        unknownCount: 0,
        isTranslationRevealed: false,
      );

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(
        makeTestableWidget(const MemoriseWordsScreen(groupId: '1')),
      );

      expect(find.text('luggage'), findsOneWidget);
      expect(find.text('ˈlʌɡ.ɪdʒ'), findsOneWidget);
      expect(find.text('Reveal Translation'), findsOneWidget);
      expect(find.text('Don\'t Know'), findsOneWidget);
      expect(find.text('Know'), findsOneWidget);
    });

    testWidgets('shows translation when revealed', (tester) async {
      final state = MemoriseInProgress(
        currentWord: testWord,
        currentIndex: 0,
        totalWords: 1,
        knownCount: 0,
        unknownCount: 0,
        isTranslationRevealed: true,
      );

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(
        makeTestableWidget(const MemoriseWordsScreen(groupId: '1')),
      );

      expect(find.text('багаж'), findsOneWidget);
      expect(find.text('Reveal Translation'), findsNothing);
    });

    testWidgets('shows progress indicator', (tester) async {
      final state = MemoriseInProgress(
        currentWord: testWord,
        currentIndex: 1,
        totalWords: 3,
        knownCount: 1,
        unknownCount: 0,
        isTranslationRevealed: false,
      );

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(
        makeTestableWidget(const MemoriseWordsScreen(groupId: '1')),
      );

      expect(find.text('Card 2 of 3'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows statistics card when completed', (tester) async {
      const state = MemoriseCompleted(
        totalWords: 10,
        knownCount: 8,
        unknownCount: 2,
      );

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(state));

      await tester.pumpWidget(
        makeTestableWidget(const MemoriseWordsScreen(groupId: '1')),
      );

      expect(find.text('Session Complete!'), findsOneWidget);
      expect(find.text('80% Accuracy'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Practice Again'), findsOneWidget);
      expect(find.text('Back to Groups'), findsOneWidget);
    });

    testWidgets('calls markKnown when Know button is tapped', (tester) async {
      final state = MemoriseInProgress(
        currentWord: testWord,
        currentIndex: 0,
        totalWords: 1,
        knownCount: 0,
        unknownCount: 0,
        isTranslationRevealed: false,
      );

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(state));
      when(() => mockCubit.markKnown()).thenReturn(null);

      await tester.pumpWidget(
        makeTestableWidget(const MemoriseWordsScreen(groupId: '1')),
      );

      await tester.tap(find.text('Know'));
      await tester.pump();

      verify(() => mockCubit.markKnown()).called(1);
    });

    testWidgets('calls markUnknown when Don\'t Know button is tapped',
        (tester) async {
      final state = MemoriseInProgress(
        currentWord: testWord,
        currentIndex: 0,
        totalWords: 1,
        knownCount: 0,
        unknownCount: 0,
        isTranslationRevealed: false,
      );

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(state));
      when(() => mockCubit.markUnknown()).thenReturn(null);

      await tester.pumpWidget(
        makeTestableWidget(const MemoriseWordsScreen(groupId: '1')),
      );

      await tester.tap(find.text('Don\'t Know'));
      await tester.pump();

      verify(() => mockCubit.markUnknown()).called(1);
    });

    testWidgets('calls reset when Practice Again button is tapped',
        (tester) async {
      const state = MemoriseCompleted(
        totalWords: 10,
        knownCount: 8,
        unknownCount: 2,
      );

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(state));
      when(() => mockCubit.reset()).thenReturn(null);

      await tester.pumpWidget(
        makeTestableWidget(const MemoriseWordsScreen(groupId: '1')),
      );

      await tester.tap(find.text('Practice Again'));
      await tester.pump();

      verify(() => mockCubit.reset()).called(1);
    });
  });
}
