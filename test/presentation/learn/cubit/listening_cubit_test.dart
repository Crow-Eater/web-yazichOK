import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/data/models/audio_record.dart';
import 'package:yazich_ok/domain/managers/audio_manager.dart';
import 'package:yazich_ok/domain/repositories/network_repository.dart';
import 'package:yazich_ok/presentation/learn/cubit/listening_cubit.dart';
import 'package:yazich_ok/presentation/learn/cubit/listening_state.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

class MockAudioManager extends Mock implements AudioManager {}

// Fake class for AudioRecord
class FakeAudioRecord extends Fake implements AudioRecord {}

void main() {
  group('ListeningCubit', () {
    late MockNetworkRepository mockNetworkRepository;
    late MockAudioManager mockAudioManager;
    late ListeningCubit cubit;

    setUpAll(() {
      registerFallbackValue(FakeAudioRecord());
    });

    setUp(() {
      mockNetworkRepository = MockNetworkRepository();
      mockAudioManager = MockAudioManager();
      cubit = ListeningCubit(mockNetworkRepository, mockAudioManager);

      // Setup mock streams - use empty streams to avoid unwanted emissions during tests
      when(() => mockAudioManager.positionStream)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockAudioManager.durationStream)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockAudioManager.playbackStateStream)
          .thenAnswer((_) => const Stream.empty());
    });

    tearDown(() {
      cubit.close();
    });

    final testRecords = [
      AudioRecord(
        id: 'a-1',
        title: 'Travel Dialogue',
        asset: 'assets/audio/travel.mp3',
        duration: '3:30',
        difficulty: 'beginner',
      ),
      AudioRecord(
        id: 'a-2',
        title: 'Shopping Exercise',
        asset: 'assets/audio/shopping.mp3',
        duration: '2:45',
      ),
    ];

    test('initial state is ListeningInitial', () {
      expect(cubit.state, const ListeningInitial());
    });

    group('loadRecords', () {
      blocTest<ListeningCubit, ListeningState>(
        'loads records and auto-selects first',
        build: () {
          when(() => mockNetworkRepository.getAudioRecords())
              .thenAnswer((_) async => testRecords);
          when(() => mockAudioManager.load(any()))
              .thenAnswer((_) async => {});
          return cubit;
        },
        act: (cubit) => cubit.loadRecords(),
        expect: () => [
          const ListeningLoading(),
          isA<ListeningLoaded>()
              .having((s) => s.selectedRecord?.id, 'selectedRecord.id', 'a-1')
              .having((s) => s.records.length, 'records.length', 2),
        ],
      );

      blocTest<ListeningCubit, ListeningState>(
        'emits error when no records',
        build: () {
          when(() => mockNetworkRepository.getAudioRecords())
              .thenAnswer((_) async => []);
          return cubit;
        },
        act: (cubit) => cubit.loadRecords(),
        expect: () => [
          const ListeningLoading(),
          const ListeningError('No audio records available'),
        ],
      );
    });

    group('play/pause', () {
      blocTest<ListeningCubit, ListeningState>(
        'calls audio manager play',
        build: () {
          when(() => mockAudioManager.play()).thenAnswer((_) async => {});
          return cubit;
        },
        act: (cubit) => cubit.play(),
        verify: (_) {
          verify(() => mockAudioManager.play()).called(1);
        },
      );

      blocTest<ListeningCubit, ListeningState>(
        'calls audio manager pause',
        build: () {
          when(() => mockAudioManager.pause()).thenAnswer((_) async => {});
          return cubit;
        },
        act: (cubit) => cubit.pause(),
        verify: (_) {
          verify(() => mockAudioManager.pause()).called(1);
        },
      );
    });
  });
}
