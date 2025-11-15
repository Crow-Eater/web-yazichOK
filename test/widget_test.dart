import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yazich_ok/main.dart';
import 'package:yazich_ok/core/di/service_locator.dart';

void main() {
  setUpAll(() {
    // Initialize services before running tests
    sl.setup();
  });

  testWidgets('App initializes successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const YazichOKApp());
    await tester.pumpAndSettle();

    // App should initialize without errors
    // It will show either sign in or main screen depending on auth state
    expect(find.byType(MaterialApp), findsOneWidget);
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

  testWidgets('App uses GoRouter for navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const YazichOKApp());
    await tester.pumpAndSettle();

    // Verify that the MaterialApp uses GoRouter
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp).first);
    expect(materialApp.routerConfig, isNotNull);
  });
}
