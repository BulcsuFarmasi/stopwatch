import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/stopwatch_controls.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/display/stopwatch_display.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps/stopwatch_laps.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/layout/stopwatch_portrait.dart';

import '../../../mock_stopwatch_notifier.dart';

void main() {
  group("StopwatchPortrait", () {
    Future<void> buildWidget(
      WidgetTester tester, {
      Size size = const Size(600, 800),
    }) async {
      final StopwatchNotifier stopwatchNotifier = MockStopwatchNotifier();

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => stopwatchNotifier.build())
          .thenAnswer((_) async => StopwatchState.initial());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stopwatchNotifierProvider.overrideWith(() => stopwatchNotifier),
          ],
          child: MaterialApp(home: Scaffold(body: StopwatchPortrait())),
        ),
      );
    }

    testWidgets("should contain the 3 main widgets in a column", (
      WidgetTester tester,
    ) async {
      await buildWidget(tester);

      final Finder columnFinder = find.ancestor(
        of: find.byType(StopwatchDisplay),
        matching: find.byType(Column),
      );

      expect(columnFinder, findsOneWidget);

      expect(
        find.descendant(
          of: columnFinder,
          matching: find.byType(StopwatchDisplay),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: columnFinder, matching: find.byType(StopwatchLaps)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: columnFinder,
          matching: find.byType(StopwatchControls),
        ),
        findsOneWidget,
      );
    });

    group("StopwatchControls", () {
      testWidgets(
        "should not use compact controls when height is at least the breakpoint",
        (WidgetTester tester) async {
          await buildWidget(tester);

          final StopwatchControls stopwatchControls = tester
              .widget<StopwatchControls>(find.byType(StopwatchControls));

          expect(stopwatchControls.useCompactLayout, false);
        },
      );

      testWidgets(
        "should use compact controls when height is below the breakpoint",
        (WidgetTester tester) async {
          await buildWidget(tester, size: Size(600, 499));

          final StopwatchControls stopwatchControls = tester
              .widget<StopwatchControls>(find.byType(StopwatchControls));

          expect(stopwatchControls.useCompactLayout, true);
        },
      );
    });
  });
}
