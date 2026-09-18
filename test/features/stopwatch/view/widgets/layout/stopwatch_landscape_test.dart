import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/stopwatch_controls.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/display/stopwatch_display.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps/stopwatch_laps.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/layout/stopwatch_landscape.dart';

import '../../../mock_stopwatch_notifier.dart';

void main() {
  group("StopwatchPortrait", () {
    Future<void> buildWidget(WidgetTester tester) async {
      final StopwatchNotifier stopwatchNotifier = MockStopwatchNotifier();

      when(() => stopwatchNotifier.build())
          .thenAnswer((_) async => StopwatchState.initial());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stopwatchNotifierProvider.overrideWith(() => stopwatchNotifier),
          ],
          child: MaterialApp(home: Scaffold(body: StopwatchLandscape())),
        ),
      );
    }

    testWidgets("should contain the 3 main widgets in a row", (
      WidgetTester tester,
    ) async {
      await buildWidget(tester);

      final Finder rowFinder = find.ancestor(
        of: find.byType(StopwatchDisplay),
        matching: find.byType(Row),
      );

      expect(rowFinder, findsOneWidget);

      expect(
        find.descendant(of: rowFinder, matching: find.byType(StopwatchDisplay)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: rowFinder, matching: find.byType(StopwatchLaps)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: rowFinder,
          matching: find.byType(StopwatchControls),
        ),
        findsOneWidget,
      );
    });
  });
}
