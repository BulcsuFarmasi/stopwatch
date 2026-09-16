import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/reset_button.dart';

import '../../../mock_stopwatch_notifier.dart';

void main() {
  group("ResetButton", () {
    late MockStopwatchNotifier stopwatchNotifier;

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
          child: MaterialApp(home: ResetButton()),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      "should be enabled when status is running and actions are not blocked",
      (WidgetTester tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(status: .running),
        );

        final Finder finder = find.widgetWithText(FilledButton, "Reset");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNotNull);
      },
    );

    testWidgets(
      "should be enabled when status is paused and actions are not blocked",
      (WidgetTester tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(status: .paused),
        );

        final Finder finder = find.widgetWithText(FilledButton, "Reset");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNotNull);
      },
    );

    testWidgets(
      "should be disabled when status is inital and actions are not blocked",
      (WidgetTester tester) async {
        await buildWidget(tester);

        final Finder finder = find.widgetWithText(FilledButton, "Reset");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNull);
      },
    );

    testWidgets(
      "should be disabled when status is running and actions are blocked",
      (WidgetTester tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(
            sessionIssue: SessionIssue.clearFailed,
            status: .running,
          ),
        );

        final Finder finder = find.widgetWithText(FilledButton, "Reset");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNull);
      },
    );

    testWidgets(
      "should be disabled when status is paused and actions are blocked",
      (WidgetTester tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(
            status: .paused,
            sessionIssue: SessionIssue.clearFailed,
          ),
        );

        final Finder finder = find.widgetWithText(FilledButton, "Reset");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNull);
      },
    );

    testWidgets(
      "should be disabled when status is initial and actions are blocked",
      (WidgetTester tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(
            sessionIssue: SessionIssue.clearFailed,
          ),
        );

        final Finder finder = find.widgetWithText(FilledButton, "Reset");

        expect(finder, findsOneWidget);
        expect(tester.widget<FilledButton>(finder).onPressed, isNull);
      },
    );

    testWidgets(
      "should call notifier reset when pressed and enabled via running status",
      (WidgetTester tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(status: .running),
        );

        when(() => stopwatchNotifier.reset()).thenAnswer((_) async {});

        await tester.tap(find.widgetWithText(FilledButton, "Reset"));

        verify(() => stopwatchNotifier.reset()).called(1);
      },
    );

    testWidgets(
      "should call notifier reset when pressed and enabled via paused status",
      (WidgetTester tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(status: .paused),
        );

        when(() => stopwatchNotifier.reset()).thenAnswer((_) async {});

        await tester.tap(find.widgetWithText(FilledButton, "Reset"));

        verify(() => stopwatchNotifier.reset()).called(1);
      },
    );
  });
}
