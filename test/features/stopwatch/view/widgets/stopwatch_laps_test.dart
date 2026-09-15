import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/lap_row.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps_header.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_laps.dart';

import '../../mock_stopwatch_notifier.dart';

void main() {
  group("StopwatchLaps", () {
    late MockStopwatchNotifier stopwatchNotifier;
    const List<Lap> laps = [
      Lap(
        number: 2,
        split: Duration(milliseconds: 32),
        total: Duration(milliseconds: 64),
      ),
      Lap(
        number: 1,
        split: Duration(milliseconds: 32),
        total: Duration(milliseconds: 32),
      ),
    ];

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
          child: MaterialApp(home: StopwatchLaps()),
        ),
      );
      await tester.pump();
    }

    group("header", () {
      testWidgets("should not display header if there are no laps", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        expect(find.byType(LapsHeader), findsNothing);
      });

      testWidgets("should display header if there are laps", (
        WidgetTester tester,
      ) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(laps: laps),
        );

        expect(find.byType(LapsHeader), findsOneWidget);
      });
    });

    group("laps", () {
      testWidgets("should not display laps if there are no laps", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        expect(find.byType(LapRow), findsNothing);
      });

      testWidgets("should display the laps in the given order", (
        WidgetTester tester,
      ) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(laps: laps),
        );

        final List<LapRow> lapRows = tester
            .widgetList<LapRow>(find.byType(LapRow))
            .toList();

        expect(lapRows.length, laps.length);

        for (int i = 0; i < laps.length; i++) {
          expect(lapRows[i].lap, laps[i]);
        }
      });
    });

    group("clear laps button", () {
      testWidgets("should not display clear laps button if there are no laps", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        expect(find.widgetWithText(OutlinedButton, "Clear laps"), findsNothing);
      });

      testWidgets("should display clear laps button if there are laps", (
        WidgetTester tester,
      ) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(laps: laps),
        );

        expect(
          find.widgetWithText(OutlinedButton, "Clear laps"),
          findsOneWidget,
        );
      });

      testWidgets("should be disabled if actions are blocked", (
        WidgetTester tester,
      ) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(
            laps: laps,
            sessionIssue: SessionIssue.clearFailed,
          ),
        );

        final OutlinedButton outlinedButton = tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, "Clear laps"),
        );

        expect(outlinedButton.onPressed, isNull);
      });

      testWidgets("should be enabled if actions are not blocked", (
        WidgetTester tester,
      ) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(laps: laps),
        );

        final OutlinedButton outlinedButton = tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, "Clear laps"),
        );

        expect(outlinedButton.onPressed, isNotNull);
      });

      testWidgets("should call notifier if enabled and pressed", (
        WidgetTester tester,
      ) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(laps: laps),
        );

        when(() => stopwatchNotifier.clearLaps()).thenReturn(null);

        await tester.tap(find.widgetWithText(OutlinedButton, "Clear laps"));

        await tester.pump();

        verify(() => stopwatchNotifier.clearLaps()).called(1);
      });
    });
  });
}
