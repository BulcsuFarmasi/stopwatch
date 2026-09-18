import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/lap_button.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/pause_resume_button.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/reset_button.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/start_button.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/controls/stopwatch_controls.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/layout/button_slot.dart';

import '../../../mock_stopwatch_notifier.dart';

void main() {
  group("StopwatchControls", () {
    Future<void> buildWidget(
      WidgetTester tester, {
      Size size = const Size(600, 800),
      bool useCompactLayout = false,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final StopwatchNotifier stopwatchNotifier = MockStopwatchNotifier();

      when(() => stopwatchNotifier.build())
          .thenAnswer((_) async => StopwatchState.initial());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stopwatchNotifierProvider.overrideWith(() => stopwatchNotifier),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StopwatchControls(useCompactLayout: useCompactLayout),
            ),
          ),
        ),
      );

      await tester.pump();
    }

    void expectAllButtonsInside(Finder layout) {
      expect(
        find.descendant(of: layout, matching: find.byType(StartButton)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: layout, matching: find.byType(PauseResumeButton)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: layout, matching: find.byType(ResetButton)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: layout, matching: find.byType(LapButton)),
        findsOneWidget,
      );
    }

    group("landscape", () {
      testWidgets(
        "should display the landscape layout when useCompact layout is false",
        (WidgetTester tester) async {
          await buildWidget(tester, size: Size(800, 600));

          final Finder landscapeFinder = find.byKey(
            StopwatchControls.landscapeKey,
          );

          expect(landscapeFinder, findsOneWidget);

          expectAllButtonsInside(landscapeFinder);
        },
      );

      testWidgets(
        "should display the landscape layout when useCompact layout is true",
        (WidgetTester tester) async {
          await buildWidget(
            tester,
            size: Size(800, 600),
            useCompactLayout: true,
          );

          final Finder landscapeFinder = find.byKey(
            StopwatchControls.landscapeKey,
          );

          expect(landscapeFinder, findsOneWidget);

          expectAllButtonsInside(landscapeFinder);
        },
      );

      testWidgets("should display landscape controls in a column", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester, size: Size(800, 600), useCompactLayout: true);

        final Finder landscapeFinder = find.byKey(
          StopwatchControls.landscapeKey,
        );

        expect(tester.widget(landscapeFinder), isA<Column>());
      });
    });

    group("compact", () {
      testWidgets(
        "should display the compact layout when the width allows it",
        (WidgetTester tester) async {
          await buildWidget(tester, size: Size(350, 600));

          final Finder compactFinder = find.byKey(StopwatchControls.compactKey);

          expect(compactFinder, findsOneWidget);

          expectAllButtonsInside(compactFinder);
        },
      );

      testWidgets(
        "should display the compact layout when useCompact layout is true",
        (WidgetTester tester) async {
          await buildWidget(tester, useCompactLayout: true);

          final Finder compactFinder = find.byKey(StopwatchControls.compactKey);

          expect(compactFinder, findsOneWidget);

          expectAllButtonsInside(compactFinder);
        },
      );

      testWidgets("should display compact controls in a column with two rows", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester, useCompactLayout: true);

        final Finder compactFinder = find.byKey(StopwatchControls.compactKey);

        final Finder columnFinder = find.descendant(
          of: compactFinder,
          matching: find.byType(Column),
        );

        expect(columnFinder, findsOneWidget);

        final Finder rowFinder = find.descendant(
          of: columnFinder,
          matching: find.byType(Row),
        );

        expect(rowFinder, findsNWidgets(2));
      });
    });

    group("regular", () {
      testWidgets(
        "should display the regular layout when it's not landscape and compact",
        (WidgetTester tester) async {
          await buildWidget(tester);

          final Finder regularFinder = find.byKey(StopwatchControls.regularKey);

          expect(regularFinder, findsOneWidget);

          expectAllButtonsInside(regularFinder);
        },
      );

      testWidgets(
        "should display regular controls in a column with a row and button slot",
        (WidgetTester tester) async {
          await buildWidget(tester);

          final Finder regularFinder = find.byKey(StopwatchControls.regularKey);

          final Finder columnFinder = find.descendant(
            of: regularFinder,
            matching: find.byType(Column),
          );

          expect(columnFinder, findsOneWidget);

          final Finder rowFinder = find.descendant(
            of: columnFinder,
            matching: find.byType(Row),
          );

          expect(rowFinder, findsOne);

          final Finder buttonSlotFinder = find.descendant(
            of: columnFinder,
            matching: find.byType(ButtonSlot),
          );

          expect(buttonSlotFinder, findsOne);
        },
      );
    });
  });
}
