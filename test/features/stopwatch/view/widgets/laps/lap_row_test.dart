import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps/lap_row.dart';

void main() {
  group('LapRow', () {
    Future<void> buildWidget(WidgetTester tester, Lap lap) async {
      await tester.pumpWidget(MaterialApp(home: LapRow(lap: lap)));
    }

    testWidgets("should have the correct semantics label", (
      WidgetTester tester,
    ) async {
      final Lap lap = Lap(
        number: 2,
        split: Duration(milliseconds: 32),
        total: Duration(milliseconds: 64),
      );

      await buildWidget(tester, lap);

      expect(
        find.bySemanticsLabel(
          "Lap 2, Split: 0 minutes, 0 seconds, 32 milliseconds, Total: 0 minutes, 0 seconds, 64 milliseconds",
        ),
        findsOneWidget,
      );
    });

    testWidgets("should display the correct texts", (
      WidgetTester tester,
    ) async {
      final Lap lap = Lap(
        number: 2,
        split: Duration(milliseconds: 32),
        total: Duration(milliseconds: 64),
      );

      await buildWidget(tester, lap);

      expect(find.text("2"), findsOneWidget);
      expect(find.text("00:00.032"), findsOneWidget);
      expect(find.text("00:00.064"), findsOneWidget);
    });
  });
}
