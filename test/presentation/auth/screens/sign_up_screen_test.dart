import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web/core/di/service_locator.dart';
import 'package:web/domain/managers/auth_manager.dart';
import 'package:web/data/models/user.dart';
import 'package:web/presentation/auth/cubit/auth_cubit.dart';
import 'package:web/presentation/auth/screens/sign_up_screen.dart';
import 'package:web/core/theme/app_theme.dart';

class MockAuthManager extends Mock implements AuthManager {}

void main() {
  setUpAll(() {
    sl.setup();
  });

  group('SignUpScreen', () {
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
          child: const SignUpScreen(),
        ),
      );
    }

    testWidgets('displays all required UI elements', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Check for title and subtitle
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Start your language learning journey today'), findsOneWidget);

      // Check for form fields
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Check for password hint
      expect(find.text('Password must be at least 8 characters long'), findsOneWidget);

      // Check for terms checkbox
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.textContaining('Terms and Conditions'), findsOneWidget);
      expect(find.textContaining('Privacy Policy'), findsOneWidget);

      // Check for buttons
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign In'), findsAtLeastNWidgets(1));

      // Check for icon
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('create account button is disabled when form is empty', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      expect(createButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(createButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('create account button is disabled when terms not accepted', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Fill all fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pump();

      // Button should still be disabled (terms not accepted)
      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      final button = tester.widget<ElevatedButton>(createButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('create account button is enabled when form is filled and terms accepted',
        (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Fill all fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pump();

      // Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
      final button = tester.widget<ElevatedButton>(createButton);
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

    testWidgets('terms checkbox can be toggled', (tester) async {
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

      // Fill fields with invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalidemail',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pump();

      // Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Tap create account button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('validates password length', (tester) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Fill fields with short password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'short',
      );
      await tester.pump();

      // Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Tap create account button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Password must be at least 8 characters long'), findsAtLeastNWidgets(1));
    });

    testWidgets('calls signUp when form is submitted', (tester) async {
      when(() => authManager.signUp(any(), any())).thenAnswer((_) async => testUser);

      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pump();

      // Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      // Verify signUp was called
      verify(() => authManager.signUp('test@example.com', 'password123')).called(1);
    });

    testWidgets('shows loading indicator during sign up', (tester) async {
      when(() => authManager.signUp(any(), any())).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 1), () => testUser),
      );

      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pump();

      // Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message on failed sign up', (tester) async {
      when(() => authManager.signUp(any(), any()))
          .thenThrow(Exception('Email already exists'));

      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pump();

      // Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump();
      await tester.pump(); // Extra pump for state change

      // Should show error in snackbar
      expect(find.text('Email already exists'), findsOneWidget);
    });
  });
}
