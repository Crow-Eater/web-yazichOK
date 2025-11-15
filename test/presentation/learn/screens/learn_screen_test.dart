import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_yazichok/presentation/learn/screens/learn_screen.dart';

void main() {
  Widget makeTestableWidget() {
    return const MaterialApp(
      home: LearnScreen(),
    );
  }

  group('LearnScreen', () {
    testWidgets('displays screen title and learning options',
        (tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Choose Your Learning Path'), findsOneWidget);
      expect(find.text('Grammar Tests'), findsOneWidget);
      expect(find.text('Listening Practice'), findsOneWidget);
    });

    testWidgets('displays option descriptions', (tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(
          find.text('Practice grammar with interactive exercises'),
          findsOneWidget);
      expect(find.text('Improve comprehension with audio exercises'),
          findsOneWidget);
    });
  });
}
