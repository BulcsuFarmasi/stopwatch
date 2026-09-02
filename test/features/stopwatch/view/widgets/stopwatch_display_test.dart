import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';
import 'package:stopwatch/features/stopwatch/view/widgets/stopwatch_display.dart';

import '../../../fake_stopwatch_service.dart';

void main() {
  group('StopwatchDisplay', () {
    late FakeStopwatchService fakeStopwatchService;
    late ProviderContainer container;
    late StopwatchNotifier stopwatchNotifier;
    final int elapsedMilliseconds = 62003;

    setUp(() {
      fakeStopwatchService = FakeStopwatchService();
      container = ProviderContainer.test(
        overrides: [
          stopwatchServiceProvider.overrideWithValue(fakeStopwatchService),
        ],
      );
      stopwatchNotifier = container.read(stopwatchNotifierProvider.notifier);
    });

    Future<void> buildWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: StopwatchDisplay()),
        ),
      );
    }

    testWidgets("should have the intial correct semantics label", (
      WidgetTester tester,
    ) async {
      await buildWidget(tester);

      expect(
        find.bySemanticsLabel(
          "Elapsed time: 0 minutes, 0 seconds, 0 milliseconds",
        ),
        findsOneWidget,
      );
    });

    testWidgets("should have the correct semantics label after elapsed time", (
      WidgetTester tester,
    ) async {
      await buildWidget(tester);

      stopwatchNotifier.start();

      fakeStopwatchService.advance(Duration(milliseconds: elapsedMilliseconds));

      await tester.pump(Duration(milliseconds: 32));

      stopwatchNotifier.pause();

      expect(
        find.bySemanticsLabel(
          "Elapsed time: 1 minute, 2 seconds, 3 milliseconds",
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not expose the elapsed-time display as a live region', (
      WidgetTester tester,
    ) async {
      await buildWidget(tester);

      final SemanticsHandle handle = tester.ensureSemantics();

      final SemanticsData semantics = tester
          .getSemantics(find.byType(StopwatchDisplay))
          .getSemanticsData();

      expect(semantics.flagsCollection.isLiveRegion, isFalse);

      handle.dispose();
    });
  });
}
