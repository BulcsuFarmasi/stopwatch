import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/view/stopwatch_screen.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps/clear_laps_button.dart';

import '../mock_stopwatch_notifier.dart';

void main() {
  group("stopwatch accessibility", () {
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
          child: MaterialApp(home: StopwatchScreen()),
        ),
      );
      await tester.pump();
    }

    testWidgets('meets tap-target accessibility guidelines initially', (
      tester,
    ) async {
      await buildWidget(tester);

      final SemanticsHandle handle = tester.ensureSemantics();

      try {
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      } finally {
        handle.dispose();
      }
    });
    testWidgets(
      'meets tap-target accessibility guidelines when clear laps is present',
      (tester) async {
        await buildWidget(
          tester,
          stopwatchState: StopwatchState.initial().copyWith(
            laps: const [
              Lap(
                number: 1,
                split: Duration(milliseconds: 32),
                total: Duration(milliseconds: 32),
              ),
            ],
          ),
        );

        expect(find.byType(ClearLapsButton), findsOneWidget);

        final SemanticsHandle handle = tester.ensureSemantics();

        try {
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        } finally {
          handle.dispose();
        }
      },
    );
  });
}
