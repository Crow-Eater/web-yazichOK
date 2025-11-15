import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yazich_ok/presentation/common/widgets/loading_widget.dart';
import 'package:yazich_ok/presentation/common/widgets/error_widget.dart';
import 'package:yazich_ok/presentation/common/widgets/empty_state_widget.dart';
import 'package:yazich_ok/presentation/common/widgets/responsive_layout.dart';

void main() {
  group('Common Widgets', () {
    testWidgets('LoadingWidget displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingWidget displays with message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(message: 'Loading data...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('ErrorDisplayWidget displays correctly',
        (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              message: 'Test error message',
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retryPressed, isTrue);
    });

    testWidgets('ErrorDisplayWidget displays with custom title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              message: 'Test error',
              title: 'Custom Error Title',
            ),
          ),
        ),
      );

      expect(find.text('Custom Error Title'), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('EmptyStateWidget displays correctly',
        (WidgetTester tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No items',
              message: 'There are no items to display',
              actionLabel: 'Create Item',
              onAction: () {
                actionPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No items'), findsOneWidget);
      expect(find.text('There are no items to display'), findsOneWidget);
      expect(find.text('Create Item'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.text('Create Item'));
      await tester.pump();
      expect(actionPressed, isTrue);
    });

    testWidgets('ResponsiveLayout shows mobile on small screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: ResponsiveLayout(
                mobile: Text('Mobile'),
                tablet: Text('Tablet'),
                desktop: Text('Desktop'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('CenteredContent applies max width',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CenteredContent(
              maxWidth: 800,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(ConstrainedBox), findsWidgets);
      expect(find.byType(Center), findsAtLeastNWidgets(1));
    });
  });
}
