import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';
import 'package:stopwatch/features/stopwatch/view/stopwatch_screen.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/lap_row.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps_header.dart';

import '../../fake_stopwatch_service.dart';

void main() {
  group('StopwatchScreen', () {
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
    group('lap button', () {
      testWidgets("should be disabled when stopwatch has not started yet", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        expectButtonDisabled(tester, "Lap");
      });

      testWidgets("should be enabled when stopwatch has started", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        Finder finder = find.widgetWithText(FilledButton, "Start");

        await tester.tap(finder);
        await tester.pump();

        expectButtonEnabled(tester, "Lap");
      });
      testWidgets("should be disabled when stopwatch is paused", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        Finder finder = find.widgetWithText(FilledButton, "Start");

        await tester.tap(finder);
        await tester.pump();

        expectButtonEnabled(tester, "Lap");

        finder = find.widgetWithText(FilledButton, "Pause");

        await tester.tap(finder);
        await tester.pump();

        expectButtonDisabled(tester, "Lap");
      });

      testWidgets("should record a single lap when pressed once", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        Finder finder = find.widgetWithText(FilledButton, "Start");

        await tester.tap(finder);
        await tester.pump();

        expectButtonEnabled(tester, "Lap");

        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        finder = find.widgetWithText(FilledButton, "Lap");

        await tester.tap(finder);
        await tester.pump();

        expect(find.byType(LapsHeader), findsOneWidget);
        expect(find.byType(LapRow), findsOneWidget);
        expect(find.text("1"), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text("00:00.032"),
            matching: find.byType(LapRow),
          ),
          findsNWidgets(2),
        );
      });

      testWidgets("should record two laps when pressed twice", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        Finder finder = find.widgetWithText(FilledButton, "Start");

        await tester.tap(finder);
        await tester.pump();

        expectButtonEnabled(tester, "Lap");

        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        finder = find.widgetWithText(FilledButton, "Lap");

        await tester.tap(finder);
        await tester.pump();

        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        await tester.tap(finder);
        await tester.pump();

        expect(find.byType(LapsHeader), findsOneWidget);
        expect(find.byType(LapRow), findsNWidgets(2));
        expect(find.text("1"), findsOneWidget);
        expect(find.text("2"), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text("00:00.032"),
            matching: find.byType(LapRow),
          ),
          findsNWidgets(3),
        );
        expect(
          find.ancestor(
            of: find.text("00:00.064"),
            matching: find.byType(LapRow),
          ),
          findsOneWidget,
        );
      });
    });

    group("Clear laps button", () {
      testWidgets("should not be present initially", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        expect(find.widgetWithText(OutlinedButton, "Clear laps"), findsNothing);
      });

      testWidgets("should be present when one lap is recorded", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        Finder finder = find.widgetWithText(FilledButton, "Start");

        await tester.tap(finder);
        await tester.pump();

        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        finder = find.widgetWithText(FilledButton, "Lap");

        await tester.tap(finder);
        await tester.pump();

        expect(
          find.widgetWithText(OutlinedButton, "Clear laps"),
          findsOneWidget,
        );
      });

      testWidgets("should disappear along with the laps when pressed", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        Finder finder = find.widgetWithText(FilledButton, "Start");

        await tester.tap(finder);
        await tester.pump();

        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        finder = find.widgetWithText(FilledButton, "Lap");

        await tester.tap(finder);
        await tester.pump();

        expect(find.byType(LapRow), findsOneWidget);

        finder = find.widgetWithText(OutlinedButton, "Clear laps");

        await tester.tap(finder);
        await tester.pump();

        expect(find.byType(LapRow), findsNothing);
        expect(find.widgetWithText(OutlinedButton, "Clear laps"), findsNothing);
        expect(find.byType(LapsHeader), findsNothing);
      });
    });
  });
}
