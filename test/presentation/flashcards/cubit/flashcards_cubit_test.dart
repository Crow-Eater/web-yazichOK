import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/data/models/flash_card.dart';
import 'package:yazich_ok/data/models/word_group.dart';
import 'package:yazich_ok/domain/repositories/network_repository.dart';
import 'package:yazich_ok/presentation/flashcards/cubit/flashcards_cubit.dart';
import 'package:yazich_ok/presentation/flashcards/cubit/flashcards_state.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  group('FlashCardsCubit', () {
    late MockNetworkRepository mockNetworkRepository;
    late FlashCardsCubit cubit;

    setUp(() {
      mockNetworkRepository = MockNetworkRepository();
      cubit = FlashCardsCubit(mockNetworkRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is FlashCardsInitial', () {
      expect(cubit.state, const FlashCardsInitial());
    });

    group('loadGroups', () {
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

      blocTest<FlashCardsCubit, FlashCardsState>(
        'emits [FlashCardsLoading, FlashCardsLoaded] when successful',
        build: () {
          when(() => mockNetworkRepository.getFlashcardGroups())
              .thenAnswer((_) async => testGroups);
          return cubit;
        },
        act: (cubit) => cubit.loadGroups(),
        expect: () => [
          const FlashCardsLoading(),
          FlashCardsLoaded(testGroups),
        ],
        verify: (_) {
          verify(() => mockNetworkRepository.getFlashcardGroups()).called(1);
        },
      );

      blocTest<FlashCardsCubit, FlashCardsState>(
        'emits [FlashCardsLoading, FlashCardsError] when fails',
        build: () {
          when(() => mockNetworkRepository.getFlashcardGroups())
              .thenThrow(Exception('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.loadGroups(),
        expect: () => [
          const FlashCardsLoading(),
          isA<FlashCardsError>()
              .having((s) => s.message, 'message', contains('Network error')),
        ],
      );
    });

    group('addGroup', () {
      const groupName = 'Education';
      final mockGroups = [
        WordGroup(id: '1', title: 'Travel', words: []),
        WordGroup(id: '2', title: groupName, words: []),
      ];

      blocTest<FlashCardsCubit, FlashCardsState>(
        'adds group and reloads groups',
        build: () {
          when(() => mockNetworkRepository.addFlashcardGroup(groupName))
              .thenAnswer((_) async => {});
          when(() => mockNetworkRepository.getFlashcardGroups())
              .thenAnswer((_) async => mockGroups);
          return cubit;
        },
        act: (cubit) => cubit.addGroup(groupName),
        expect: () => [
          const FlashCardsLoading(),
          const FlashCardsLoading(), // From loadGroups call
          FlashCardsLoaded(mockGroups),
        ],
        verify: (_) {
          verify(() => mockNetworkRepository.addFlashcardGroup(groupName))
              .called(1);
          verify(() => mockNetworkRepository.getFlashcardGroups()).called(1);
        },
      );

      blocTest<FlashCardsCubit, FlashCardsState>(
        'emits error when addGroup fails',
        build: () {
          when(() => mockNetworkRepository.addFlashcardGroup(groupName))
              .thenThrow(Exception('Failed to add'));
          return cubit;
        },
        act: (cubit) => cubit.addGroup(groupName),
        expect: () => [
          const FlashCardsLoading(),
          isA<FlashCardsError>()
              .having((s) => s.message, 'message', contains('Failed to add')),
        ],
      );
    });

    group('addWord', () {
      const groupId = '1';
      final testWord = FlashCard(
        id: 'w1',
        word: 'hello',
        transcription: 'həˈloʊ',
        translation: 'привіт',
      );
      final mockGroups = [
        WordGroup(id: groupId, title: 'Greetings', words: [testWord]),
      ];

      blocTest<FlashCardsCubit, FlashCardsState>(
        'adds word and reloads groups',
        build: () {
          when(() => mockNetworkRepository.addWord(groupId, testWord))
              .thenAnswer((_) async => {});
          when(() => mockNetworkRepository.getFlashcardGroups())
              .thenAnswer((_) async => mockGroups);
          return cubit;
        },
        act: (cubit) => cubit.addWord(groupId, testWord),
        expect: () => [
          const FlashCardsLoading(),
          const FlashCardsLoading(), // From loadGroups call
          FlashCardsLoaded(mockGroups),
        ],
        verify: (_) {
          verify(() => mockNetworkRepository.addWord(groupId, testWord))
              .called(1);
          verify(() => mockNetworkRepository.getFlashcardGroups()).called(1);
        },
      );
    });

    group('deleteGroup', () {
      const groupId = '1';
      final mockGroups = [
        WordGroup(id: '2', title: 'Remaining', words: []),
      ];

      blocTest<FlashCardsCubit, FlashCardsState>(
        'deletes group and reloads groups',
        build: () {
          when(() => mockNetworkRepository.deleteGroup(groupId))
              .thenAnswer((_) async => {});
          when(() => mockNetworkRepository.getFlashcardGroups())
              .thenAnswer((_) async => mockGroups);
          return cubit;
        },
        act: (cubit) => cubit.deleteGroup(groupId),
        expect: () => [
          const FlashCardsLoading(),
          const FlashCardsLoading(), // From loadGroups call
          FlashCardsLoaded(mockGroups),
        ],
        verify: (_) {
          verify(() => mockNetworkRepository.deleteGroup(groupId)).called(1);
          verify(() => mockNetworkRepository.getFlashcardGroups()).called(1);
        },
      );
    });

    group('deleteWord', () {
      const wordId = 'w1';
      final mockGroups = [
        WordGroup(id: '1', title: 'Travel', words: []),
      ];

      blocTest<FlashCardsCubit, FlashCardsState>(
        'deletes word and reloads groups',
        build: () {
          when(() => mockNetworkRepository.deleteWord(wordId))
              .thenAnswer((_) async => {});
          when(() => mockNetworkRepository.getFlashcardGroups())
              .thenAnswer((_) async => mockGroups);
          return cubit;
        },
        act: (cubit) => cubit.deleteWord(wordId),
        expect: () => [
          const FlashCardsLoading(),
          const FlashCardsLoading(), // From loadGroups call
          FlashCardsLoaded(mockGroups),
        ],
        verify: (_) {
          verify(() => mockNetworkRepository.deleteWord(wordId)).called(1);
          verify(() => mockNetworkRepository.getFlashcardGroups()).called(1);
        },
      );
    });

    group('getWordsForGroup', () {
      const groupId = '1';
      final testWords = [
        FlashCard(
          id: 'w1',
          word: 'luggage',
          transcription: 'ˈlʌɡ.ɪdʒ',
          translation: 'багаж',
        ),
      ];

      test('returns words for group when successful', () async {
        when(() => mockNetworkRepository.getWordsForGroup(groupId))
            .thenAnswer((_) async => testWords);

        final result = await cubit.getWordsForGroup(groupId);

        expect(result, testWords);
        verify(() => mockNetworkRepository.getWordsForGroup(groupId)).called(1);
      });

      test('emits error and returns empty list when fails', () async {
        when(() => mockNetworkRepository.getWordsForGroup(groupId))
            .thenThrow(Exception('Not found'));

        final result = await cubit.getWordsForGroup(groupId);

        expect(result, []);
        expect(cubit.state, isA<FlashCardsError>());
      });
    });
  });
}
