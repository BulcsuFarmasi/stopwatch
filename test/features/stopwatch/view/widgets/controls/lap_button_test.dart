import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/lap_button.dart';

import '../../../mock_stopwatch_notifier.dart';

void main() {
  group("LapButton", () {
    late MockStopwatchNotifier stopwatchNotifier;

    Future<void> buildWidget(
      WidgetTester tester, {
      StopwatchState? stopwatchState,
    }) async {
      stopwatchNotifier = MockStopwatchNotifier();
      when(() => stopwatchNotifier.build()).thenAnswer(
        (_) async =>
            stopwatchState ??
            StopwatchState.initial().copyWith(status: .running),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stopwatchNotifierProvider.overrideWith(() => stopwatchNotifier),
          ],
          child: MaterialApp(home: LapButton()),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      "should be enabled when state is running and actions are not blocked",
      (WidgetTester tester) async {
        await buildWidget(tester);

        final Finder finder = find.widgetWithText(FilledButton, "Lap");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNotNull);
      },
    );

    testWidgets(
      "should be disabled when state is initial and actions are not blocked",
      (WidgetTester tester) async {
        await buildWidget(tester, stopwatchState: StopwatchState.initial());

        final Finder finder = find.widgetWithText(FilledButton, "Lap");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNull);
      },
    );

    testWidgets(
      "should be disabled when state is paused and actions are not blocked",
      (WidgetTester tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(status: .paused),
        );

        final Finder finder = find.widgetWithText(FilledButton, "Lap");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNull);
      },
    );

    testWidgets(
      "should be disabled when state is running and actions are blocked",
      (WidgetTester tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(
            status: .running,
            sessionIssue: SessionIssue.clearFailed,
          ),
        );

        final Finder finder = find.widgetWithText(FilledButton, "Lap");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNull);
      },
    );

    testWidgets(
      "should be disabled when state is initial and actions are blocked",
      (WidgetTester tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(
            sessionIssue: SessionIssue.clearFailed,
          ),
        );

        final Finder finder = find.widgetWithText(FilledButton, "Lap");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNull);
      },
    );

    testWidgets(
      "should be disabled when state is paused and actions are blocked",
      (WidgetTester tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(
            status: .paused,
            sessionIssue: SessionIssue.clearFailed,
          ),
        );

        final Finder finder = find.widgetWithText(FilledButton, "Lap");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNull);
      },
    );

    testWidgets("should call notifier recordLap when pressed", (
      WidgetTester tester,
    ) async {
      await buildWidget(tester);

      await tester.tap(find.widgetWithText(FilledButton, "Lap"));

      verify(() => stopwatchNotifier.recordLap()).called(1);
    });
  });
}
