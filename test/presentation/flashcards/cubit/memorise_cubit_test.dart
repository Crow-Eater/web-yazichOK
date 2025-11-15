import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/data/models/flash_card.dart';
import 'package:yazich_ok/domain/repositories/network_repository.dart';
import 'package:yazich_ok/presentation/flashcards/cubit/memorise_cubit.dart';
import 'package:yazich_ok/presentation/flashcards/cubit/memorise_state.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  group('MemoriseCubit', () {
    late MockNetworkRepository mockNetworkRepository;
    late MemoriseCubit cubit;

    setUp(() {
      mockNetworkRepository = MockNetworkRepository();
      cubit = MemoriseCubit(mockNetworkRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is MemoriseInitial', () {
      expect(cubit.state, const MemoriseInitial());
    });

    group('loadGroup', () {
      const groupId = '1';
      final testWords = [
        FlashCard(
          id: 'w1',
          word: 'luggage',
          transcription: 'ˈlʌɡ.ɪdʒ',
          translation: 'багаж',
        ),
        FlashCard(
          id: 'w2',
          word: 'departure',
          transcription: 'dɪˈpɑːr.tʃər',
          translation: 'відправлення',
        ),
      ];

      blocTest<MemoriseCubit, MemoriseState>(
        'emits [MemoriseLoading, MemoriseInProgress] when successful',
        build: () {
          when(() => mockNetworkRepository.getWordsForGroup(groupId))
              .thenAnswer((_) async => testWords);
          return cubit;
        },
        act: (cubit) => cubit.loadGroup(groupId),
        expect: () => [
          const MemoriseLoading(),
          MemoriseInProgress(
            currentWord: testWords[0],
            currentIndex: 0,
            totalWords: 2,
            knownCount: 0,
            unknownCount: 0,
            isTranslationRevealed: false,
          ),
        ],
        verify: (_) {
          verify(() => mockNetworkRepository.getWordsForGroup(groupId))
              .called(1);
        },
      );

      blocTest<MemoriseCubit, MemoriseState>(
        'emits [MemoriseLoading, MemoriseEmpty] when group is empty',
        build: () {
          when(() => mockNetworkRepository.getWordsForGroup(groupId))
              .thenAnswer((_) async => []);
          return cubit;
        },
        act: (cubit) => cubit.loadGroup(groupId),
        expect: () => [
          const MemoriseLoading(),
          const MemoriseEmpty(),
        ],
      );

      blocTest<MemoriseCubit, MemoriseState>(
        'emits [MemoriseLoading, MemoriseError] when fails',
        build: () {
          when(() => mockNetworkRepository.getWordsForGroup(groupId))
              .thenThrow(Exception('Not found'));
          return cubit;
        },
        act: (cubit) => cubit.loadGroup(groupId),
        expect: () => [
          const MemoriseLoading(),
          isA<MemoriseError>()
              .having((s) => s.message, 'message', contains('Not found')),
        ],
      );
    });

    group('revealTranslation', () {
      const groupId = '1';
      final testWords = [
        FlashCard(
          id: 'w1',
          word: 'luggage',
          transcription: 'ˈlʌɡ.ɪdʒ',
          translation: 'багаж',
        ),
      ];

      blocTest<MemoriseCubit, MemoriseState>(
        'reveals translation for current word',
        build: () {
          when(() => mockNetworkRepository.getWordsForGroup(groupId))
              .thenAnswer((_) async => testWords);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadGroup(groupId);
          cubit.revealTranslation();
        },
        skip: 2, // Skip loading and initial in-progress states
        expect: () => [
          MemoriseInProgress(
            currentWord: testWords[0],
            currentIndex: 0,
            totalWords: 1,
            knownCount: 0,
            unknownCount: 0,
            isTranslationRevealed: true,
          ),
        ],
      );
    });

    group('markKnown', () {
      const groupId = '1';
      final testWords = [
        FlashCard(
          id: 'w1',
          word: 'luggage',
          transcription: 'ˈlʌɡ.ɪdʒ',
          translation: 'багаж',
        ),
        FlashCard(
          id: 'w2',
          word: 'departure',
          transcription: 'dɪˈpɑːr.tʃər',
          translation: 'відправлення',
        ),
      ];

      blocTest<MemoriseCubit, MemoriseState>(
        'increments known count and advances to next word',
        build: () {
          when(() => mockNetworkRepository.getWordsForGroup(groupId))
              .thenAnswer((_) async => testWords);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadGroup(groupId);
          cubit.markKnown();
        },
        skip: 2, // Skip loading and initial in-progress states
        expect: () => [
          MemoriseInProgress(
            currentWord: testWords[1],
            currentIndex: 1,
            totalWords: 2,
            knownCount: 1,
            unknownCount: 0,
            isTranslationRevealed: false,
          ),
        ],
      );

      blocTest<MemoriseCubit, MemoriseState>(
        'emits MemoriseCompleted when last word is marked as known',
        build: () {
          when(() => mockNetworkRepository.getWordsForGroup(groupId))
              .thenAnswer((_) async => [testWords[0]]);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadGroup(groupId);
          cubit.markKnown();
        },
        skip: 2, // Skip loading and initial in-progress states
        expect: () => [
          const MemoriseCompleted(
            totalWords: 1,
            knownCount: 1,
            unknownCount: 0,
          ),
        ],
      );
    });

    group('markUnknown', () {
      const groupId = '1';
      final testWords = [
        FlashCard(
          id: 'w1',
          word: 'luggage',
          transcription: 'ˈlʌɡ.ɪdʒ',
          translation: 'багаж',
        ),
        FlashCard(
          id: 'w2',
          word: 'departure',
          transcription: 'dɪˈpɑːr.tʃər',
          translation: 'відправлення',
        ),
      ];

      blocTest<MemoriseCubit, MemoriseState>(
        'increments unknown count and advances to next word',
        build: () {
          when(() => mockNetworkRepository.getWordsForGroup(groupId))
              .thenAnswer((_) async => testWords);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadGroup(groupId);
          cubit.markUnknown();
        },
        skip: 2, // Skip loading and initial in-progress states
        expect: () => [
          MemoriseInProgress(
            currentWord: testWords[1],
            currentIndex: 1,
            totalWords: 2,
            knownCount: 0,
            unknownCount: 1,
            isTranslationRevealed: false,
          ),
        ],
      );

      blocTest<MemoriseCubit, MemoriseState>(
        'emits MemoriseCompleted when last word is marked as unknown',
        build: () {
          when(() => mockNetworkRepository.getWordsForGroup(groupId))
              .thenAnswer((_) async => [testWords[0]]);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadGroup(groupId);
          cubit.markUnknown();
        },
        skip: 2, // Skip loading and initial in-progress states
        expect: () => [
          const MemoriseCompleted(
            totalWords: 1,
            knownCount: 0,
            unknownCount: 1,
          ),
        ],
      );
    });

    group('reset', () {
      const groupId = '1';
      final testWords = [
        FlashCard(
          id: 'w1',
          word: 'luggage',
          transcription: 'ˈlʌɡ.ɪdʒ',
          translation: 'багаж',
        ),
      ];

      blocTest<MemoriseCubit, MemoriseState>(
        'resets to first word with zero counts',
        build: () {
          when(() => mockNetworkRepository.getWordsForGroup(groupId))
              .thenAnswer((_) async => testWords);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadGroup(groupId);
          cubit.markKnown();
          cubit.reset();
        },
        skip: 3, // Skip loading, initial in-progress, and completed states
        expect: () => [
          MemoriseInProgress(
            currentWord: testWords[0],
            currentIndex: 0,
            totalWords: 1,
            knownCount: 0,
            unknownCount: 0,
            isTranslationRevealed: false,
          ),
        ],
      );

      blocTest<MemoriseCubit, MemoriseState>(
        'emits MemoriseInitial when no words loaded',
        build: () => cubit,
        act: (cubit) => cubit.reset(),
        expect: () => [const MemoriseInitial()],
      );
    });

    group('accuracy calculation', () {
      test('calculates accuracy correctly', () {
        const completed = MemoriseCompleted(
          totalWords: 10,
          knownCount: 8,
          unknownCount: 2,
        );

        expect(completed.accuracy, 80.0);
      });

      test('returns 0 accuracy when no words', () {
        const completed = MemoriseCompleted(
          totalWords: 0,
          knownCount: 0,
          unknownCount: 0,
        );

        expect(completed.accuracy, 0.0);
      });
    });
  });
}
