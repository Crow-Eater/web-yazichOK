import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/presentation/profile/screens/profile_screen.dart';
import 'package:yazich_ok/presentation/auth/cubit/auth_cubit.dart';
import 'package:yazich_ok/presentation/auth/cubit/auth_state.dart';
import 'package:yazich_ok/data/models/user.dart';

// Mock class
class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
  });

  Widget createTestWidget() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/signin',
          builder: (context, state) => const Scaffold(body: Text('Sign In')),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('ProfileScreen', () {
    const testUser = User(
      id: 'test-id',
      email: 'test@example.com',
      displayName: 'Test User',
    );

    testWidgets('displays user information when authenticated',
        (WidgetTester tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(const AuthAuthenticated(testUser));
      when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('T'), findsOneWidget); // Avatar initial
    });

    testWidgets('displays default user when not authenticated',
        (WidgetTester tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthUnauthenticated());
      when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('User'), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('U'), findsOneWidget); // Avatar initial
    });

    testWidgets('displays learning statistics', (WidgetTester tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(const AuthAuthenticated(testUser));
      when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Learning Statistics'), findsOneWidget);
      expect(find.text('Words Learned'), findsOneWidget);
      expect(find.text('127'), findsOneWidget);
      expect(find.text('Practice Sessions'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('Streak Days'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Articles Read'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('displays settings section', (WidgetTester tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(const AuthAuthenticated(testUser));
      when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Language Preferences'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('displays sign out button', (WidgetTester tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(const AuthAuthenticated(testUser));
      when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(
        find.widgetWithText(OutlinedButton, 'Sign Out'),
        findsOneWidget,
      );
    });

    testWidgets('shows snackbar when tapping Edit Profile',
        (WidgetTester tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(const AuthAuthenticated(testUser));
      when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Edit Profile'));
      await tester.pump();

      expect(find.text('Edit Profile coming soon!'), findsOneWidget);
    });

    testWidgets('shows About dialog when tapping About',
        (WidgetTester tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(const AuthAuthenticated(testUser));
      when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(find.text('yazichOK'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets('has correct app bar title', (WidgetTester tester) async {
      when(() => mockAuthCubit.state)
          .thenReturn(const AuthAuthenticated(testUser));
      when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
    });
  });
}
