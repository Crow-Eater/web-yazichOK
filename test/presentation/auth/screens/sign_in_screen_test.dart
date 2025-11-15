import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web/core/di/service_locator.dart';
import 'package:web/domain/managers/auth_manager.dart';
import 'package:web/data/models/user.dart';
import 'package:web/presentation/auth/cubit/auth_cubit.dart';
import 'package:web/presentation/auth/screens/sign_in_screen.dart';
import 'package:web/core/theme/app_theme.dart';

class MockAuthManager extends Mock implements AuthManager {}

void main() {
  setUpAll(() {
    sl.setup();
  });

  group('SignInScreen', () {
    late AuthManager authManager;
    late User testUser;

    setUp(() {
      authManager = MockAuthManager();
      testUser = const User(
        id: '1',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      when(() => authManager.isAuthenticated()).thenAnswer((_) async => false);
    });

    Widget createScreen() {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authManager),
          child: const SignInScreen(),
        ),
      );
    }

    testWidgets('displays all required UI elements', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Check for title and subtitle
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Continue your English learning journey'), findsOneWidget);

      // Check for form fields
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Check for checkbox
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Remember me for 30 days'), findsOneWidget);

      // Check for buttons
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Sign up for free'), findsOneWidget);

      // Check for icon
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('log in button is disabled when form is empty', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      final logInButton = find.widgetWithText(ElevatedButton, 'Log In');
      expect(logInButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(logInButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('log in button is enabled when form is filled', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Enter email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.pump();

      // Enter password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pump();

      final logInButton = find.widgetWithText(ElevatedButton, 'Log In');
      final button = tester.widget<ElevatedButton>(logInButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      expect(passwordField, findsOneWidget);

      // Visibility icon should be present initially
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Icon should change to visibility_off
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('remember me checkbox can be toggled', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Initially unchecked
      var checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.value, isFalse);

      // Tap checkbox
      await tester.tap(checkbox);
      await tester.pump();

      // Should be checked
      checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.value, isTrue);
    });

    testWidgets('validates email field', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalidemail',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pump();

      // Tap log in button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('calls signIn when form is submitted', (tester) async {
      when(() => authManager.signIn(any(), any())).thenAnswer((_) async => testUser);

      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pump();

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();

      // Verify signIn was called
      verify(() => authManager.signIn('test@example.com', 'password123')).called(1);
    });

    testWidgets('shows loading indicator during sign in', (tester) async {
      when(() => authManager.signIn(any(), any())).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 1), () => testUser),
      );

      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pump();

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message on failed sign in', (tester) async {
      when(() => authManager.signIn(any(), any()))
          .thenThrow(Exception('Invalid credentials'));

      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrongpassword',
      );
      await tester.pump();

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();
      await tester.pump(); // Extra pump for state change

      // Should show error in snackbar
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
