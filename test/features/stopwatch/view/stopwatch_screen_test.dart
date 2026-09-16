import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/view/stopwatch_screen.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/layout/stopwatch_landscape.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/layout/stopwatch_portrait.dart';
import 'package:stopwatch/shared/widgets/app_lifecycle_observer.dart';
import 'package:stopwatch/shared/widgets/stopwatch_alert_dialog.dart';

import '../mock_stopwatch_notifier.dart';

void main() {
  group("StopwatchScreen", () {
    late MockStopwatchNotifier stopwatchNotifier;

    Future<void> buildWidget(
      WidgetTester tester, {
      StopwatchState? stopwatchState,
      Size size = const Size(600, 800),
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

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

    group("title", () {
      testWidgets("should display the title", (WidgetTester tester) async {
        await buildWidget(tester);

        expect(find.text("Stopwatch"), findsOneWidget);
      });
    });

    group("layout", () {
      testWidgets("should display portrait when the layout is portrait", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        expect(find.byType(StopwatchPortrait), findsOneWidget);
        expect(find.byType(StopwatchLandscape), findsNothing);
      });

      testWidgets("should display landscape when the layout is landscape", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester, size: Size(800, 600));

        expect(find.byType(StopwatchLandscape), findsOneWidget);
        expect(find.byType(StopwatchPortrait), findsNothing);
      });
    });

    group("lifecycle observer", () {
      testWidgets("onVisible should call notifier's startRefresh", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        clearInteractions(stopwatchNotifier);

        final AppLifecycleObserver observer = tester
            .widget<AppLifecycleObserver>(find.byType(AppLifecycleObserver));

        observer.onVisible();

        verify(() => stopwatchNotifier.startRefresh()).called(1);
      });

      testWidgets("onHidden should call notifier's stopRefresh", (
        WidgetTester tester,
      ) async {
        await buildWidget(tester);

        clearInteractions(stopwatchNotifier);

        final AppLifecycleObserver observer = tester
            .widget<AppLifecycleObserver>(find.byType(AppLifecycleObserver));

        observer.onHidden();

        verify(() => stopwatchNotifier.stopRefresh()).called(1);
      });
    });

    group("session issue", () {
      group("invalid saved session", () {
        testWidgets("should display a snackbar with the appropriate text", (
          WidgetTester tester,
        ) async {
          await buildWidget(
            tester,
            stopwatchState: StopwatchState.withIssue(.invalidSavedSession),
          );

          expect(
            find.widgetWithText(
              SnackBar,
              "We couldn't recover your stopwatch session, so we started a new one.",
            ),
            findsOneWidget,
          );
        });

        testWidgets("should call notifier's acknowledgeInvalidSavedSession", (
          WidgetTester tester,
        ) async {
          await buildWidget(
            tester,
            stopwatchState: StopwatchState.withIssue(.invalidSavedSession),
          );

          verify(() => stopwatchNotifier.acknowledgeInvalidSavedSession())
              .called(1);
        });
      });

      group("save failed", () {
        testWidgets("should display a snackbar with the appropriate text", (
          WidgetTester tester,
        ) async {
          await buildWidget(
            tester,
            stopwatchState: StopwatchState.withIssue(.saveFailed),
          );

          expect(
            find.widgetWithText(
              SnackBar,
              "We couldn't save your stopwatch session. Your latest changes may not be restored.",
            ),
            findsOneWidget,
          );
        });
      });

      group("read failed", () {
        testWidgets("should display an alert dialog with appropriate content", (
          WidgetTester tester,
        ) async {
          await buildWidget(
            tester,
            stopwatchState: StopwatchState.withIssue(.readFailed),
          );

          final Finder stopwatchAlertDialogFinder = find.byType(
            StopwatchAlertDialog,
          );

          expect(stopwatchAlertDialogFinder, findsOneWidget);

          expect(
            find.descendant(
              of: stopwatchAlertDialogFinder,
              matching: find.text("Read error"),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: stopwatchAlertDialogFinder,
              matching: find.text(
                "We couldn't read your stopwatch session. Please try again or discard it.",
              ),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: stopwatchAlertDialogFinder,
              matching: find.widgetWithText(TextButton, "Discard"),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: stopwatchAlertDialogFinder,
              matching: find.widgetWithText(TextButton, "Try again"),
            ),
            findsOneWidget,
          );
        });

        testWidgets(
          "alert's discard should call notifier's clear saved session",
          (WidgetTester tester) async {
            await buildWidget(
              tester,
              stopwatchState: StopwatchState.withIssue(.readFailed),
            );

            when(() => stopwatchNotifier.clearSavedSession())
                .thenAnswer((_) async {});

            await tester.tap(
              find.descendant(
                of: find.byType(StopwatchAlertDialog),
                matching: find.widgetWithText(TextButton, "Discard"),
              ),
            );

            verify(() => stopwatchNotifier.clearSavedSession()).called(1);
          },
        );

        testWidgets(
          "alert's try again should call notifier's retry session restore",
          (WidgetTester tester) async {
            await buildWidget(
              tester,
              stopwatchState: StopwatchState.withIssue(.readFailed),
            );

            when(() => stopwatchNotifier.retrySessionRestore())
                .thenAnswer((_) async {});

            await tester.tap(
              find.descendant(
                of: find.byType(StopwatchAlertDialog),
                matching: find.widgetWithText(TextButton, "Try again"),
              ),
            );

            verify(() => stopwatchNotifier.retrySessionRestore()).called(1);
          },
        );
      });

      group("clear failed", () {
        testWidgets("should display an alert dialog with appropriate content", (
          WidgetTester tester,
        ) async {
          await buildWidget(
            tester,
            stopwatchState: StopwatchState.withIssue(.clearFailed),
          );

          final Finder stopwatchAlertDialogFinder = find.byType(
            StopwatchAlertDialog,
          );

          expect(stopwatchAlertDialogFinder, findsOneWidget);

          expect(
            find.descendant(
              of: stopwatchAlertDialogFinder,
              matching: find.text("Clear error"),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: stopwatchAlertDialogFinder,
              matching: find.text(
                "We couldn't clear your stopwatch session. Please try again.",
              ),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: stopwatchAlertDialogFinder,
              matching: find.widgetWithText(TextButton, "Try again"),
            ),
            findsOneWidget,
          );
        });

        testWidgets(
          "alert's try again should call notifier's clear saved session",
          (WidgetTester tester) async {
            await buildWidget(
              tester,
              stopwatchState: StopwatchState.withIssue(.clearFailed),
            );

            when(() => stopwatchNotifier.clearSavedSession())
                .thenAnswer((_) async {});

            await tester.tap(
              find.descendant(
                of: find.byType(StopwatchAlertDialog),
                matching: find.widgetWithText(TextButton, "Try again"),
              ),
            );

            verify(() => stopwatchNotifier.clearSavedSession()).called(1);
          },
        );
      });
    });
  });
}
