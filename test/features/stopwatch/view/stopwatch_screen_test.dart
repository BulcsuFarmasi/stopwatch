import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';
import 'package:stopwatch/features/stopwatch/view/stopwatch_screen.dart';

import '../../fake_stopwatch_service.dart';

void main() {
  group('StopWatchScreen', () {
    late FakeStopwatchService fakeStopwatchService;
    const int elapsedMilliseconds = 32;

    setUp(() {
      fakeStopwatchService = FakeStopwatchService();
    });

    Future<void> buildWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stopwatchServiceProvider.overrideWithValue(fakeStopwatchService),
          ],
          child: MaterialApp(home: StopwatchScreen()),
        ),
      );
    }

    void expectButtonEnabled(WidgetTester tester, String label) {
      final Finder finder = find.widgetWithText(FilledButton, label);

      expect(finder, findsOneWidget);
      expect(tester.widget<FilledButton>(finder).onPressed, isNotNull);
    }

    void expectButtonDisabled(WidgetTester tester, String label) {
      final Finder finder = find.widgetWithText(FilledButton, label);

      expect(finder, findsOneWidget);
      expect(tester.widget<FilledButton>(finder).onPressed, isNull);
    }

    group('start button', () {
      testWidgets("should be active initially", (WidgetTester tester) async {
        await buildWidget(tester);

        expectButtonEnabled(tester, 'Start');
      });

      testWidgets(
        "when clicking on it should start the stopwatch and be disabled",
        (WidgetTester tester) async {
          await buildWidget(tester);

          Finder finder = find.widgetWithText(FilledButton, 'Start');

          await tester.tap(finder);
          await tester.pump();

          expect(fakeStopwatchService.startCalls, 1);

          fakeStopwatchService.advance(
            Duration(milliseconds: elapsedMilliseconds),
          );
          await tester.pump(Duration(milliseconds: elapsedMilliseconds));

          expect(find.text("00:00.032"), findsOneWidget);

          expectButtonDisabled(tester, 'Start');
        },
      );
    });

    group('pause / resume button', () {
      testWidgets("should be disabled initially", (WidgetTester tester) async {
        await buildWidget(tester);

        expectButtonDisabled(tester, 'Pause');
      });

      testWidgets(
        "when clicking on it should pause the stopwatch and the text should be changed",
        (WidgetTester tester) async {
          await buildWidget(tester);

          Finder finder = find.widgetWithText(FilledButton, 'Start');

          await tester.tap(finder);
          await tester.pump();

          fakeStopwatchService.advance(
            Duration(milliseconds: elapsedMilliseconds),
          );
          await tester.pump(Duration(milliseconds: elapsedMilliseconds));

          expect(find.text("00:00.032"), findsOneWidget);

          expectButtonEnabled(tester, 'Pause');

          finder = find.widgetWithText(FilledButton, 'Pause');

          await tester.tap(finder);
          await tester.pump();

          expect(fakeStopwatchService.stopCalls, 1);

          await tester.pump(Duration(milliseconds: elapsedMilliseconds));

          expect(find.text("00:00.032"), findsOneWidget);

          expectButtonEnabled(tester, 'Resume');
        },
      );

      testWidgets(
        "when clicking it after pausing it should restart the timer",
        (WidgetTester tester) async {
          await buildWidget(tester);

          Finder finder = find.widgetWithText(FilledButton, 'Start');

          await tester.tap(finder);
          await tester.pump();

          fakeStopwatchService.advance(
            Duration(milliseconds: elapsedMilliseconds),
          );
          await tester.pump(Duration(milliseconds: elapsedMilliseconds));

          finder = find.widgetWithText(FilledButton, 'Pause');

          await tester.tap(finder);
          await tester.pump();

          finder = find.widgetWithText(FilledButton, 'Resume');

          await tester.tap(finder);
          await tester.pump();

          expect(fakeStopwatchService.startCalls, 2);

          fakeStopwatchService.advance(
            Duration(milliseconds: elapsedMilliseconds),
          );
          await tester.pump(Duration(milliseconds: elapsedMilliseconds));

          expect(find.text("00:00.064"), findsOneWidget);
        },
      );

      testWidgets("when clicking it again should change text back and forth", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        Finder finder = find.widgetWithText(FilledButton, 'Start');

        await tester.tap(finder);
        await tester.pump();

        finder = find.widgetWithText(FilledButton, 'Pause');
        expect(finder, findsOneWidget);

        await tester.tap(finder);
        await tester.pump();

        finder = find.widgetWithText(FilledButton, 'Resume');
        expect(finder, findsOneWidget);

        await tester.tap(finder);
        await tester.pump();

        finder = find.widgetWithText(FilledButton, 'Pause');
        expect(finder, findsOneWidget);
      });
    });

    group('reset button', () {
      testWidgets("should be disabled initially", (WidgetTester tester) async {
        await buildWidget(tester);

        expectButtonDisabled(tester, 'Reset');
      });

      testWidgets(
        "when clicking on it should reset the stopwatch and be disabled",
        (WidgetTester tester) async {
          await buildWidget(tester);

          Finder finder = find.widgetWithText(FilledButton, 'Start');

          await tester.tap(finder);
          await tester.pump();

          fakeStopwatchService.advance(
            Duration(milliseconds: elapsedMilliseconds),
          );
          await tester.pump(Duration(milliseconds: elapsedMilliseconds));

          expect(find.text("00:00.032"), findsOneWidget);

          expectButtonEnabled(tester, 'Reset');

          finder = find.widgetWithText(FilledButton, "Reset");

          await tester.tap(finder);
          await tester.pump();

          expect(fakeStopwatchService.resetCalls, 1);

          expect(find.text("00:00.000"), findsOneWidget);

          expectButtonDisabled(tester, "Reset");
          expectButtonEnabled(tester, "Start");
          expectButtonDisabled(tester, "Pause");
        },
      );
    });
  });
}
