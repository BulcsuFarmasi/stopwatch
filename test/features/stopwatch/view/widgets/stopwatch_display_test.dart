import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/analog_clock.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/digital_clock.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_display.dart';

import '../../mock_stopwatch_notifier.dart';

void main() {
  group('StopwatchDisplay', () {
    late MockStopwatchNotifier stopwatchNotifier;
    const Duration elapsed = Duration(minutes: 1, seconds: 2, milliseconds: 3);

    Future<void> buildWidget(
      WidgetTester tester, {
      StopwatchState? stopwatchState,
    }) async {
      stopwatchNotifier = MockStopwatchNotifier();
      when(() => stopwatchNotifier.build())
          .thenAnswer((_) async => stopwatchState ?? StopwatchState.initial());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stopwatchNotifierProvider.overrideWith(() => stopwatchNotifier),
          ],
          child: MaterialApp(home: StopwatchDisplay()),
        ),
      );
      await tester.pump();
    }

    group("Semantics", () {
      testWidgets("should have the initial correct semantics label", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        expect(
          find.bySemanticsLabel(
            "Elapsed time: 0 minutes, 0 seconds, 0 milliseconds",
          ),
          findsOneWidget,
        );
      });

      testWidgets(
        "should have the correct semantics label after elapsed time",
        (WidgetTester tester) async {
          await buildWidget(
            tester,
            stopwatchState: StopwatchState.initial().copyWith(elapsed: elapsed),
          );

          expect(
            find.bySemanticsLabel(
              "Elapsed time: 1 minute, 2 seconds, 3 milliseconds",
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets('does not expose the elapsed-time display as a live region', (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        final SemanticsHandle handle = tester.ensureSemantics();

        try {
          final SemanticsData semantics = tester
              .getSemantics(find.byType(StopwatchDisplay))
              .getSemanticsData();

          expect(semantics.flagsCollection.isLiveRegion, isFalse);
        } finally {
          handle.dispose();
        }
      });
    });

    group("AnalogClock", () {
      testWidgets("should display the analog clock with the correct value", (
        WidgetTester tester,
      ) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(elapsed: elapsed),
        );

        final AnalogClock analogClock = tester.widget<AnalogClock>(
          find.byType(AnalogClock),
        );

        expect(analogClock.elapsed, elapsed);
      });
    });

    group("DigitalClock", () {
      testWidgets("should display the digital clock with the correct value", (
        WidgetTester tester,
      ) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(elapsed: elapsed),
        );

        final DigitalClock digitalClock = tester.widget<DigitalClock>(
          find.byType(DigitalClock),
        );

        expect(digitalClock.elapsed, elapsed);
      });
    });
  });
}
