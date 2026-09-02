import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps_header.dart';

void main() {
  group('LapsHeader', () {
    Future<void> buildWidget(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LapsHeader()));
    }

    testWidgets("should have the correct semantics label", (
      WidgetTester tester,
    ) async {
      await buildWidget(tester);

      expect(
        find.bySemanticsLabel("Laps. Columns: number, split, total"),
        findsOneWidget,
      );
    });
  });
}
