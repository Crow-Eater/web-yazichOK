import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/core/di/service_locator.dart';
import 'package:yazich_ok/domain/managers/auth_manager.dart';
import 'package:yazich_ok/data/models/user.dart';
import 'package:yazich_ok/presentation/auth/cubit/auth_cubit.dart';
import 'package:yazich_ok/presentation/main/screens/main_screen.dart';
import 'package:yazich_ok/core/theme/app_theme.dart';

class MockAuthManager extends Mock implements AuthManager {}

void main() {
  setUpAll(() {
    sl.setup();
  });

  group('MainScreen', () {
    late AuthManager authManager;
    late User testUser;

    setUp(() {
      authManager = MockAuthManager();
      testUser = const User(
        id: '1',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      when(() => authManager.isAuthenticated()).thenAnswer((_) async => true);
      when(() => authManager.getCurrentUser()).thenAnswer((_) async => testUser);
    });

    Widget createScreen() {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider<AuthCubit>(
              create: (_) => AuthCubit(authManager),
              child: const MainScreen(),
            ),
          ),
          GoRoute(
            path: '/signin',
            builder: (context, state) => const Scaffold(body: Text('Sign In')),
          ),
          GoRoute(
            path: '/speaking/topics',
            builder: (context, state) => const Scaffold(body: Text('Speaking Topics')),
          ),
          GoRoute(
            path: '/flashcards',
            builder: (context, state) => const Scaffold(body: Text('Flashcards')),
          ),
          GoRoute(
            path: '/articles/:id',
            builder: (context, state) => const Scaffold(body: Text('Article')),
          ),
        ],
      );

      return MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      );
    }

    testWidgets('displays user greeting', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Check for user greeting
      expect(find.textContaining('Hello, Test User'), findsOneWidget);
      expect(find.text('Ready to practice?'), findsOneWidget);
    });

    testWidgets('displays user avatar with initial', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Check for user avatar with initial
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('T'), findsOneWidget); // First letter of "Test User"
    });

    testWidgets('displays notification icon', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Check for notification icon
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('displays practice features section', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Check for section title
      expect(find.text('Practice Features'), findsOneWidget);

      // Check for feature cards
      expect(find.text('Speech Practice'), findsOneWidget);
      expect(find.text('Improve pronunciation'), findsOneWidget);
      expect(find.text('Flashcards'), findsOneWidget);
      expect(find.text('Learn new words'), findsOneWidget);

      // Check for icons
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.style), findsOneWidget);
    });

    testWidgets('displays recommended articles section', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Check for section title
      expect(find.text('Recommended Articles'), findsOneWidget);

      // Check for article cards
      expect(find.text('The Future of Technology'), findsOneWidget);
      expect(find.text('Climate Change Solutions'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('5 min read'), findsOneWidget);
      expect(find.text('4 min read'), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Check for bottom navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Practice'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('speech practice card is tappable', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Find and tap speech practice card
      final speechCard = find.text('Speech Practice');
      expect(speechCard, findsOneWidget);

      final inkWell = find.ancestor(
        of: speechCard,
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsOneWidget);
    });

    testWidgets('flashcards card is tappable', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Find and tap flashcards card
      final flashcardsCard = find.text('Flashcards');
      expect(flashcardsCard, findsOneWidget);

      final inkWell = find.ancestor(
        of: flashcardsCard,
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsOneWidget);
    });

    testWidgets('article cards are tappable', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Find article cards
      final article1 = find.text('The Future of Technology');
      expect(article1, findsOneWidget);

      final inkWell1 = find.ancestor(
        of: article1,
        matching: find.byType(InkWell),
      );
      expect(inkWell1, findsOneWidget);

      final article2 = find.text('Climate Change Solutions');
      expect(article2, findsOneWidget);

      final inkWell2 = find.ancestor(
        of: article2,
        matching: find.byType(InkWell),
      );
      expect(inkWell2, findsOneWidget);
    });

    testWidgets('bottom navigation items have correct icons', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      expect(bottomNav.items.length, 4);
      expect(bottomNav.items[0].icon, isA<Icon>());
      expect(bottomNav.items[1].icon, isA<Icon>());
      expect(bottomNav.items[2].icon, isA<Icon>());
      expect(bottomNav.items[3].icon, isA<Icon>());
    });

    testWidgets('shows weekly progress sidebar on wide screens', (tester) async {
      // Set screen size to wide
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Check for weekly progress section
      expect(find.text('Weekly Progress'), findsOneWidget);
      expect(find.text('Words Learned'), findsOneWidget);
      expect(find.text('127'), findsOneWidget);
      expect(find.text('Practice Sessions'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('Streak Days'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);

      // Reset screen size
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('hides weekly progress sidebar on narrow screens', (tester) async {
      // Set screen size to narrow
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Weekly progress should not be visible
      expect(find.text('Weekly Progress'), findsNothing);

      // Reset screen size
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('displays correct initial state for bottom navigation', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      // Should start at index 0 (Home)
      expect(bottomNav.currentIndex, 0);
    });
  });
}
