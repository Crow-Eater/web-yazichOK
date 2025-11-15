import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_yazichok/data/models/audio_record.dart';
import 'package:web_yazichok/domain/managers/audio_manager.dart';
import 'package:web_yazichok/domain/repositories/network_repository.dart';
import 'package:web_yazichok/presentation/learn/cubit/listening_cubit.dart';
import 'package:web_yazichok/presentation/learn/cubit/listening_state.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

class MockAudioManager extends Mock implements AudioManager {}

void main() {
  group('ListeningCubit', () {
    late MockNetworkRepository mockNetworkRepository;
    late MockAudioManager mockAudioManager;
    late ListeningCubit cubit;

    setUp(() {
      mockNetworkRepository = MockNetworkRepository();
      mockAudioManager = MockAudioManager();
      cubit = ListeningCubit(mockNetworkRepository, mockAudioManager);

      // Setup mock streams
      when(() => mockAudioManager.positionStream)
          .thenAnswer((_) => Stream.value(Duration.zero));
      when(() => mockAudioManager.durationStream)
          .thenAnswer((_) => Stream.value(const Duration(minutes: 2)));
      when(() => mockAudioManager.playbackStateStream)
          .thenAnswer((_) => Stream.value(false));
    });

    tearDown(() {
      cubit.close();
    });

    final testRecords = [
      AudioRecord(
        id: 'a-1',
        title: 'Travel Dialogue',
        asset: 'assets/audio/travel.mp3',
        difficulty: 'beginner',
      ),
      AudioRecord(
        id: 'a-2',
        title: 'Shopping Exercise',
        asset: 'assets/audio/shopping.mp3',
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
