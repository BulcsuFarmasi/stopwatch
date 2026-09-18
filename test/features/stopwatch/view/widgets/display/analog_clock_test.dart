import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/display/analog_clock.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/display/analog_clock_face_painter.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/display/analog_clock_hands_painter.dart';

void main() {
  group("AnalogClock", () {
    const Duration elapsed = Duration(minutes: 1, seconds: 2, milliseconds: 3);

    Future<void> buildWidget({required WidgetTester tester}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox.square(
            dimension: 200,
            child: AnalogClock(elapsed: elapsed),
          ),
        ),
      );
    }

    testWidgets("should contain a CustomPaint with AnalogClockFacePainter", (
      WidgetTester tester,
    ) async {
      await buildWidget(tester: tester);

      final List<CustomPaint> customPaints = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(AnalogClock),
              matching: find.byType(CustomPaint),
            ),
          )
          .toList();

      final List<CustomPainter?> painters = customPaints
          .map((CustomPaint paint) => paint.painter)
          .toList();

      expect(painters, contains(isA<AnalogClockFacePainter>()));
    });

    testWidgets(
      "should contain a CustomPaint with AnalogClockHandsPainter and forward elapsed time to it",
      (WidgetTester tester) async {
        await buildWidget(tester: tester);

        final List<CustomPaint> customPaints = tester
            .widgetList<CustomPaint>(
              find.descendant(
                of: find.byType(AnalogClock),
                matching: find.byType(CustomPaint),
              ),
            )
            .toList();

        final List<CustomPainter?> painters = customPaints
            .map((CustomPaint paint) => paint.painter)
            .toList();

        expect(painters, contains(isA<AnalogClockHandsPainter>()));

        final AnalogClockHandsPainter analogClockHandsPainter = painters
            .whereType<AnalogClockHandsPainter>()
            .single;

        expect(analogClockHandsPainter.elapsed, elapsed);
      },
    );
  });
}
