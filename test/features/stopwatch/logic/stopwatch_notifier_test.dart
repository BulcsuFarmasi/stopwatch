import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';

import 'fake_stopwatch_service.dart';

void main() {
  group('StopWatchNotifier', () {
    late FakeStopwatchService fakeStopwatchService;
    late ProviderContainer container;
    late StopwatchNotifier stopwatchNotifier;
    const int elapsedMiliseconds = 32;
    setUp(() {
      fakeStopwatchService = FakeStopwatchService();
      container = ProviderContainer(
        overrides: [
          stopwatchServiceProvider.overrideWithValue(fakeStopwatchService),
        ],
      );
      stopwatchNotifier = container.read(stopwatchNotifierProvider.notifier);
    });

    test('should start stopwatch, when calling start', () {
      fakeAsync((FakeAsync async) {
        stopwatchNotifier.start();
        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMiliseconds),
        );

        async.elapse(Duration(milliseconds: elapsedMiliseconds));

        final StopwatchState state = container.read(stopwatchNotifierProvider);

        expect(fakeStopwatchService.startCalls, 1);
        expect(fakeStopwatchService.isRunning, true);
        expect(state.status, StopwatchStatus.running);
        expect(state.elapsed, Duration(milliseconds: elapsedMiliseconds));
      });
    });
    test(
      'multiple start call should not start the stopwatch multiple times',
      () {
        stopwatchNotifier.start();
        stopwatchNotifier.start();
        stopwatchNotifier.start();

        expect(fakeStopwatchService.startCalls, 1);
      },
    );
    test('pause should pause the stopwatch', () {
      fakeAsync((FakeAsync async) {
        stopwatchNotifier.start();
        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMiliseconds),
        );

        async.elapse(Duration(milliseconds: elapsedMiliseconds));

        StopwatchState state = container.read(stopwatchNotifierProvider);

        expect(fakeStopwatchService.startCalls, 1);
        expect(fakeStopwatchService.isRunning, true);
        expect(state.status, StopwatchStatus.running);
        expect(state.elapsed, Duration(milliseconds: elapsedMiliseconds));

        stopwatchNotifier.pause();
        async.elapse(Duration(milliseconds: elapsedMiliseconds));
        state = container.read(stopwatchNotifierProvider);

        expect(fakeStopwatchService.stopCalls, 1);
        expect(state.status, StopwatchStatus.paused);
        expect(fakeStopwatchService.isRunning, false);
        expect(state.elapsed, Duration(milliseconds: elapsedMiliseconds));
      });
    });
    test('reset should reset the stopwatch', () {
      fakeAsync((FakeAsync async) {
        stopwatchNotifier.start();
        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMiliseconds),
        );

        async.elapse(Duration(milliseconds: elapsedMiliseconds));

        StopwatchState state = container.read(stopwatchNotifierProvider);

        expect(fakeStopwatchService.startCalls, 1);
        expect(fakeStopwatchService.isRunning, true);
        expect(state.status, StopwatchStatus.running);
        expect(state.elapsed, Duration(milliseconds: elapsedMiliseconds));

        stopwatchNotifier.reset();
        async.elapse(Duration(milliseconds: elapsedMiliseconds));
        state = container.read(stopwatchNotifierProvider);

        expect(fakeStopwatchService.resetCalls, 1);
        expect(state.status, StopwatchStatus.initial);
        expect(fakeStopwatchService.isRunning, false);
        expect(state.elapsed, Duration.zero);
      });
    });
  });
}
