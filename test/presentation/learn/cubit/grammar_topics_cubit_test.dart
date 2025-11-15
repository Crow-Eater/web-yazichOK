import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/data/models/grammar_topic.dart';
import 'package:yazich_ok/domain/repositories/network_repository.dart';
import 'package:yazich_ok/presentation/learn/cubit/grammar_topics_cubit.dart';
import 'package:yazich_ok/presentation/learn/cubit/grammar_topics_state.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  group('GrammarTopicsCubit', () {
    late MockNetworkRepository mockNetworkRepository;
    late GrammarTopicsCubit cubit;

    setUp(() {
      mockNetworkRepository = MockNetworkRepository();
      cubit = GrammarTopicsCubit(mockNetworkRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is GrammarTopicsInitial', () {
      expect(cubit.state, const GrammarTopicsInitial());
    });

    group('loadTopics', () {
      final testTopics = [
        GrammarTopic(
          id: 't-1',
          title: 'Articles',
          questionCount: 10,
          description: 'Learn about articles',
        ),
        GrammarTopic(
          id: 't-2',
          title: 'Tenses',
          questionCount: 12,
        ),
      ];

      blocTest<GrammarTopicsCubit, GrammarTopicsState>(
        'emits [Loading, Loaded] when successful',
        build: () {
          when(() => mockNetworkRepository.getGrammarTopics())
              .thenAnswer((_) async => testTopics);
          return cubit;
        },
        act: (cubit) => cubit.loadTopics(),
        expect: () => [
          const GrammarTopicsLoading(),
          GrammarTopicsLoaded(testTopics),
        ],
        verify: (_) {
          verify(() => mockNetworkRepository.getGrammarTopics()).called(1);
        },
      );

      blocTest<GrammarTopicsCubit, GrammarTopicsState>(
        'emits [Loading, Error] when fails',
        build: () {
          when(() => mockNetworkRepository.getGrammarTopics())
              .thenThrow(Exception('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.loadTopics(),
        expect: () => [
          const GrammarTopicsLoading(),
          isA<GrammarTopicsError>()
              .having((s) => s.message, 'message', contains('Network error')),
        ],
      );
    });
  });
}
