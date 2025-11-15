import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/data/models/speaking_topic.dart';
import 'package:yazich_ok/presentation/speaking/cubit/speech_cubit.dart';
import 'package:yazich_ok/presentation/speaking/cubit/speech_state.dart';
import 'package:yazich_ok/presentation/speaking/screens/speaking_topics_screen.dart';

class MockSpeechCubit extends Mock implements SpeechCubit {}

// Fake class for SpeakingTopic
class FakeSpeakingTopic extends Fake implements SpeakingTopic {}

void main() {
  late MockSpeechCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(FakeSpeakingTopic());
  });

  setUp(() {
    mockCubit = MockSpeechCubit();
  });

  Widget makeTestableWidget(Widget child) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<SpeechCubit>.value(
            value: mockCubit,
            child: child,
          ),
        ),
        GoRoute(
          path: '/recording',
          builder: (context, state) => const Scaffold(body: Text('Recording')),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  final testTopics = [
    const SpeakingTopic(
      id: 'st-1',
      title: 'Describe your favorite vacation',
      description: 'Talk about a memorable trip you took',
      difficulty: 'intermediate',
      timeLimit: 120,
    ),
    const SpeakingTopic(
      id: 'st-2',
      title: 'Discuss your daily routine',
      description: 'Describe a typical day in your life',
      difficulty: 'beginner',
      timeLimit: 90,
    ),
  ];

  group('SpeakingTopicsScreen', () {
    testWidgets('shows loading indicator when state is SpeechTopicsLoading',
        (tester) async {
      when(() => mockCubit.state).thenReturn(const SpeechTopicsLoading());
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const SpeechTopicsLoading()));
      when(() => mockCubit.loadTopics()).thenAnswer((_) async {});

      await tester.pumpWidget(
        makeTestableWidget(const SpeakingTopicsScreen()),
      );
      await tester.pump(); // Pump for initState callback

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when state is SpeechError',
        (tester) async {
      const errorMessage = 'Failed to load topics';
      when(() => mockCubit.state).thenReturn(const SpeechError(errorMessage));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const SpeechError(errorMessage)));
      when(() => mockCubit.loadTopics()).thenAnswer((_) async {});

      await tester.pumpWidget(
        makeTestableWidget(const SpeakingTopicsScreen()),
      );
      await tester.pump(); // Pump for initState callback

      expect(find.text('Error'), findsOneWidget);
      expect(find.textContaining(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows empty state when topics list is empty',
        (tester) async {
      when(() => mockCubit.state)
          .thenReturn(const SpeechTopicsLoaded([]));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(const SpeechTopicsLoaded([])));
      when(() => mockCubit.loadTopics()).thenAnswer((_) async {});

      await tester.pumpWidget(
        makeTestableWidget(const SpeakingTopicsScreen()),
      );
      await tester.pump(); // Pump for initState callback

      expect(find.text('No Topics Available'), findsOneWidget);
      expect(
          find.text('Check back later for new speaking topics'), findsOneWidget);
    });

    testWidgets('displays list of topics when state is SpeechTopicsLoaded',
        (tester) async {
      when(() => mockCubit.state).thenReturn(SpeechTopicsLoaded(testTopics));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(SpeechTopicsLoaded(testTopics)));
      when(() => mockCubit.loadTopics()).thenAnswer((_) async {});

      await tester.pumpWidget(
        makeTestableWidget(const SpeakingTopicsScreen()),
      );
      await tester.pump(); // Pump for initState callback

      expect(find.text('Choose a Topic'), findsOneWidget);
      expect(find.text('Select a topic to practice your speaking skills'),
          findsOneWidget);
      expect(find.text('Describe your favorite vacation'), findsOneWidget);
      expect(find.text('Discuss your daily routine'), findsOneWidget);
    });

    testWidgets('displays topic details correctly', (tester) async {
      when(() => mockCubit.state).thenReturn(SpeechTopicsLoaded(testTopics));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(SpeechTopicsLoaded(testTopics)));
      when(() => mockCubit.loadTopics()).thenAnswer((_) async {});

      await tester.pumpWidget(
        makeTestableWidget(const SpeakingTopicsScreen()),
      );
      await tester.pump(); // Pump for initState callback

      // Check first topic details
      expect(find.text('intermediate'), findsOneWidget);
      expect(find.text('beginner'), findsOneWidget);
      expect(find.text('2min'), findsAtLeastNWidgets(1));
      expect(find.text('1min 30s'), findsOneWidget);
    });

    testWidgets('calls selectTopic when topic is tapped', (tester) async {
      when(() => mockCubit.state).thenReturn(SpeechTopicsLoaded(testTopics));
      when(() => mockCubit.stream)
          .thenAnswer((_) => Stream.value(SpeechTopicsLoaded(testTopics)));
      when(() => mockCubit.loadTopics()).thenAnswer((_) async {});
      when(() => mockCubit.selectTopic(any())).thenReturn(null);

      await tester.pumpWidget(
        makeTestableWidget(const SpeakingTopicsScreen()),
      );
      await tester.pump(); // Pump for initState callback

      await tester.tap(find.text('Describe your favorite vacation'));
      await tester.pump();

      verify(() => mockCubit.selectTopic(testTopics.first)).called(1);
    });
  });
}
