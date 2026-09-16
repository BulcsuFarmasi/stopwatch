import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/display/digital_clock.dart';

void main() {
  group("DigitalClock", () {
    Future<void> buildWidget({
      required WidgetTester tester,
      required Duration elapsed,
    }) async {
      await tester.pumpWidget(
        MaterialApp(home: DigitalClock(elapsed: elapsed, scale: 1)),
      );
    }

    testWidgets("should display zero elapsed time", (
      WidgetTester tester,
    ) async {
      await buildWidget(tester: tester, elapsed: Duration.zero);

      expect(find.text("00:00.000"), findsOneWidget);
    });

    testWidgets("should display elapsed time", (WidgetTester tester) async {
      await buildWidget(
        tester: tester,
        elapsed: Duration(minutes: 1, seconds: 2, milliseconds: 3),
      );

      expect(find.text("01:02.003"), findsOneWidget);
    });
  });
}
