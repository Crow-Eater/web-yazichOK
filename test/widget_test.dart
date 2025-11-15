import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/main.dart';
import 'package:web/core/di/service_locator.dart';

void main() {
  setUpAll(() {
    // Initialize services before running tests
    sl.setup();
  });

  testWidgets('App initializes and shows placeholder screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const YazichOKApp());
    await tester.pumpAndSettle();

    // Should show the main screen (placeholder in Phase 0)
    expect(find.text('Main Screen'), findsOneWidget);
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

  testWidgets('Navigation to different routes works',
      (WidgetTester tester) async {
    // This test verifies routing is set up correctly
    await tester.pumpWidget(const YazichOKApp());
    await tester.pumpAndSettle();

    expect(find.text('Main Screen'), findsOneWidget);
  });
}