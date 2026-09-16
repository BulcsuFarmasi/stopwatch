import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps/clear_laps_button.dart';

import '../../../mock_stopwatch_notifier.dart';

void main() {
  group("ClearLapsButton", () {
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
          child: MaterialApp(home: ClearLapsButton()),
        ),
      );
      await tester.pump();
    }

    testWidgets("should be disabled if actions are blocked", (
      WidgetTester tester,
    ) async {
      await buildWidget(
        tester,
        stopwatchState: StopwatchState.initial().copyWith(
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
      await buildWidget(tester);

      final OutlinedButton outlinedButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, "Clear laps"),
      );

      expect(outlinedButton.onPressed, isNotNull);
    });

    testWidgets("should call notifier if enabled and pressed", (
      WidgetTester tester,
    ) async {
      await buildWidget(tester);

      when(() => stopwatchNotifier.clearLaps()).thenReturn(null);

      await tester.tap(find.widgetWithText(OutlinedButton, "Clear laps"));

      await tester.pump();

      verify(() => stopwatchNotifier.clearLaps()).called(1);
    });
  });
}
