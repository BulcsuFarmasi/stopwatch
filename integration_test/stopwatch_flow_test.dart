import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository_impl.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/display/digital_clock.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/laps/lap_row.dart';
import 'package:stopwatch/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('completes the primary stopwatch journey', (
    WidgetTester tester,
  ) async {
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();

    Future<void> clearSavedSession() =>
        preferences.remove(StopwatchSessionRepositoryImpl.sharedPreferencesKey);

    await clearSavedSession();
    addTearDown(clearSavedSession);

    app.main();
    await tester.pumpAndSettle();

    expect(getElapsedTime(tester), Duration.zero);
    expect(findButton("Start"), findsOneWidget);

    await tester.tap(findButton("Start"));
    await tester.pump();
    await waitForRealTime(tester);

    final Duration runningElapsed = getElapsedTime(tester);
    expect(runningElapsed, greaterThan(Duration.zero));

    await tester.tap(findButton("Lap"));
    await tester.pump();

    expect(find.byType(LapRow), findsOneWidget);
    final LapRow lapRow = tester.widget(find.byType(LapRow));
    expect(lapRow.lap.number, 1);
    expect(lapRow.lap.total, greaterThan(Duration.zero));

    await tester.tap(findButton("Pause"));
    await tester.pump();

    expect(findButton("Resume"), findsOneWidget);
    final Duration pausedElapsed = getElapsedTime(tester);

    await waitForRealTime(tester);

    expect(getElapsedTime(tester), pausedElapsed);

    await tester.tap(findButton("Resume"));
    await tester.pump();
    await waitForRealTime(tester);

    expect(getElapsedTime(tester), greaterThan(pausedElapsed));

    await tester.tap(findButton("Reset"));
    await tester.pumpAndSettle();

    expect(getElapsedTime(tester), Duration.zero);
    expect(find.byType(LapRow), findsNothing);
    expect(findButton("Start"), findsOneWidget);
  });

  Finder findButton(String label) => find.widgetWithText(FilledButton, label);

  Duration getElapsedTime(WidgetTester tester) =>
      tester.widget<DigitalClock>(find.byType(DigitalClock)).elapsed;

  Future<void> waitForRealTime(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 320)),
    );
    await tester.pump();
  }
}
