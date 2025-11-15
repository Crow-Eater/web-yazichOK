import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/data/models/flash_card.dart';
import 'package:yazich_ok/data/models/word_group.dart';
import 'package:yazich_ok/presentation/flashcards/cubit/flashcards_cubit.dart';
import 'package:yazich_ok/presentation/flashcards/cubit/flashcards_state.dart';
import 'package:yazich_ok/presentation/flashcards/screens/flashcards_screen.dart';

class MockFlashCardsCubit extends Mock implements FlashCardsCubit {}

void main() {
  late MockFlashCardsCubit mockCubit;

  setUp(() {
    mockCubit = MockFlashCardsCubit();
  });

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<FlashCardsCubit>.value(
        value: mockCubit,
        child: child,
      ),
    );
  }

  group('FlashCardsScreen', () {
    testWidgets('shows loading indicator when state is FlashCardsLoading',
        (tester) async {
      when(() => mockCubit.state).thenReturn(const FlashCardsLoading());
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const FlashCardsLoading()));

      await tester.pumpWidget(makeTestableWidget(const FlashCardsScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when state is FlashCardsError',
        (tester) async {
      const errorMessage = 'Failed to load groups';
      when(() => mockCubit.state)
          .thenReturn(const FlashCardsError(errorMessage));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const FlashCardsError(errorMessage)));

      await tester.pumpWidget(makeTestableWidget(const FlashCardsScreen()));

      expect(find.text('Error'), findsOneWidget);
      expect(find.textContaining(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows empty state when no groups exist', (tester) async {
      when(() => mockCubit.state).thenReturn(const FlashCardsLoaded([]));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const FlashCardsLoaded([])));

      await tester.pumpWidget(makeTestableWidget(const FlashCardsScreen()));

      expect(find.text('No Word Groups'), findsOneWidget);
      expect(find.text('Create your first group to start learning'),
          findsOneWidget);
      expect(find.text('Create Group'), findsOneWidget);
    });

    testWidgets('shows list of groups when groups exist', (tester) async {
      final testGroups = [
        WordGroup(
          id: '1',
          title: 'Travel',
          words: [
            FlashCard(
              id: 'w1',
              word: 'luggage',
              transcription: 'ˈlʌɡ.ɪdʒ',
              translation: 'багаж',
            ),
          ],
        ),
        WordGroup(
          id: '2',
          title: 'Cafe',
          words: [],
        ),
      ];

      when(() => mockCubit.state).thenReturn(FlashCardsLoaded(testGroups));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(FlashCardsLoaded(testGroups)));

      await tester.pumpWidget(makeTestableWidget(const FlashCardsScreen()));

      expect(find.text('Travel'), findsOneWidget);
      expect(find.text('Cafe'), findsOneWidget);
      expect(find.text('1 word'), findsOneWidget);
      expect(find.text('0 words'), findsOneWidget);
    });

    testWidgets('shows FAB when groups are loaded', (tester) async {
      when(() => mockCubit.state).thenReturn(const FlashCardsLoaded([]));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const FlashCardsLoaded([])));

      await tester.pumpWidget(makeTestableWidget(const FlashCardsScreen()));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('has add word button in app bar', (tester) async {
      when(() => mockCubit.state).thenReturn(const FlashCardsLoaded([]));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const FlashCardsLoaded([])));

      await tester.pumpWidget(makeTestableWidget(const FlashCardsScreen()));

      expect(find.widgetWithIcon(IconButton, Icons.add), findsOneWidget);
    });

    testWidgets('calls loadGroups when retry button is tapped',
        (tester) async {
      when(() => mockCubit.state)
          .thenReturn(const FlashCardsError('Error'));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const FlashCardsError('Error')));
      when(() => mockCubit.loadGroups()).thenAnswer((_) async {});

      await tester.pumpWidget(makeTestableWidget(const FlashCardsScreen()));

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockCubit.loadGroups()).called(1);
    });
  });
}
