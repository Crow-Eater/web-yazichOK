import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yazich_ok/main.dart';
import 'package:yazich_ok/core/di/service_locator.dart';

void main() {
  setUpAll(() {
    // Initialize services before running tests
    sl.setup();
  });

  testWidgets('App initializes and shows sign in screen when not authenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(const YazichOKApp());
    await tester.pumpAndSettle();

    // Should redirect to sign in screen when user is not authenticated
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Continue your English learning journey'), findsOneWidget);
  });

  testWidgets('App uses correct theme', (WidgetTester tester) async {
    await tester.pumpWidget(const YazichOKApp());
    await tester.pumpAndSettle();

    // Verify app uses Material 3
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp).first);
    expect(materialApp.theme?.useMaterial3, isTrue);

    // Verify theme is not null
    expect(materialApp.theme, isNotNull);
  });

  testWidgets('Navigation to sign up screen works',
      (WidgetTester tester) async {
    // This test verifies routing is set up correctly
    await tester.pumpWidget(const YazichOKApp());
    await tester.pumpAndSettle();

    // Should be on sign in screen initially
    expect(find.text('Welcome Back'), findsOneWidget);

    // Tap sign up link
    await tester.tap(find.text('Sign up for free'));
    await tester.pumpAndSettle();

    // Should navigate to sign up screen
    expect(find.text('Create your account'), findsOneWidget);
  });
}