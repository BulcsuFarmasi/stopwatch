import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';

import '../../fake_stopwatch_service.dart';

void main() {
  group('StopwatchNotifier', () {
    late FakeStopwatchService fakeStopwatchService;
    late ProviderContainer container;
    late StopwatchNotifier stopwatchNotifier;
    const int elapsedMilliseconds = 32;
    setUp(() {
      fakeStopwatchService = FakeStopwatchService();
      container = ProviderContainer.test(
        overrides: [
          stopwatchServiceProvider.overrideWithValue(fakeStopwatchService),
        ],
      );
      stopwatchNotifier = container.read(stopwatchNotifierProvider.notifier);
    });

    group('start', () {
      test('should start stopwatch, when calling start', () {
        fakeAsync((FakeAsync async) {
          stopwatchNotifier.start();
          fakeStopwatchService.advance(
            Duration(milliseconds: elapsedMilliseconds),
          );

          async.elapse(Duration(milliseconds: elapsedMilliseconds));

          final StopwatchState state = container.read(
            stopwatchNotifierProvider,
          );

          expect(fakeStopwatchService.startCalls, 1);
          expect(fakeStopwatchService.isRunning, true);
          expect(state.status, StopwatchStatus.running);
          expect(state.elapsed, Duration(milliseconds: elapsedMilliseconds));
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
    });
    group('pause', () {
      test('should pause the stopwatch', () {
        fakeAsync((FakeAsync async) {
          stopwatchNotifier.start();
          fakeStopwatchService.advance(
            Duration(milliseconds: elapsedMilliseconds),
          );

          async.elapse(Duration(milliseconds: elapsedMilliseconds));

          StopwatchState state = container.read(stopwatchNotifierProvider);

          expect(fakeStopwatchService.startCalls, 1);
          expect(fakeStopwatchService.isRunning, true);
          expect(state.status, StopwatchStatus.running);
          expect(state.elapsed, Duration(milliseconds: elapsedMilliseconds));

          stopwatchNotifier.pause();
          async.elapse(Duration(milliseconds: elapsedMilliseconds));
          state = container.read(stopwatchNotifierProvider);

          expect(fakeStopwatchService.stopCalls, 1);
          expect(state.status, StopwatchStatus.paused);
          expect(fakeStopwatchService.isRunning, false);
          expect(state.elapsed, Duration(milliseconds: elapsedMilliseconds));
        });
      });
    });

    group('reset', () {
      test('should reset the stopwatch and clear elapsed time and laps', () {
        fakeAsync((FakeAsync async) {
          stopwatchNotifier.start();
          fakeStopwatchService.advance(
            Duration(milliseconds: elapsedMilliseconds),
          );

          async.elapse(Duration(milliseconds: elapsedMilliseconds));

          stopwatchNotifier.recordLap();

          StopwatchState state = container.read(stopwatchNotifierProvider);

          expect(fakeStopwatchService.startCalls, 1);
          expect(fakeStopwatchService.isRunning, true);
          expect(state.status, StopwatchStatus.running);
          expect(state.elapsed, Duration(milliseconds: elapsedMilliseconds));
          expect(state.laps.length, 1);

          stopwatchNotifier.reset();
          async.elapse(Duration(milliseconds: elapsedMilliseconds));
          state = container.read(stopwatchNotifierProvider);

          expect(fakeStopwatchService.resetCalls, 1);
          expect(state.status, StopwatchStatus.initial);
          expect(fakeStopwatchService.isRunning, false);
          expect(state.elapsed, Duration.zero);
          expect(state.laps.length, 0);
        });
      });
    });
    group('recordLap', () {
      test('should register the first lap', () {
        stopwatchNotifier.start();
        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        stopwatchNotifier.recordLap();

        StopwatchState state = container.read(stopwatchNotifierProvider);

        expect(state.laps.length, 1);
        expect(state.laps.first.number, 1);
        expect(
          state.laps.first.total,
          Duration(milliseconds: elapsedMilliseconds),
        );
        expect(
          state.laps.first.split,
          Duration(milliseconds: elapsedMilliseconds),
        );
      });

      test('should register another lap', () {
        stopwatchNotifier.start();
        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        stopwatchNotifier.recordLap();

        StopwatchState state = container.read(stopwatchNotifierProvider);

        expect(state.laps.length, 1);

        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        stopwatchNotifier.recordLap();

        state = container.read(stopwatchNotifierProvider);

        expect(state.laps.length, 2);
        expect(state.laps.first.number, 2);
        expect(
          state.laps.first.total,
          Duration(milliseconds: elapsedMilliseconds) * 2,
        );
        expect(
          state.laps.first.split,
          Duration(milliseconds: elapsedMilliseconds),
        );
      });

      test('should not record lap while stopwatch is not yet running', () {
        StopwatchState state = container.read(stopwatchNotifierProvider);

        expect(state.laps, isEmpty);

        stopwatchNotifier.recordLap();

        state = container.read(stopwatchNotifierProvider);

        expect(state.laps, isEmpty);
      });

      test('should not record lap while stopwatch is paused', () {
        stopwatchNotifier.start();
        StopwatchState state = container.read(stopwatchNotifierProvider);

        expect(state.laps, isEmpty);

        stopwatchNotifier.pause();

        state = container.read(stopwatchNotifierProvider);

        expect(state.laps, isEmpty);

        stopwatchNotifier.recordLap();

        state = container.read(stopwatchNotifierProvider);

        expect(state.laps, isEmpty);
      });
    });
    group('clear laps', () {
      test('should clear the laps', () {
        stopwatchNotifier.start();
        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        stopwatchNotifier.recordLap();

        StopwatchState state = container.read(stopwatchNotifierProvider);

        expect(state.laps.length, 1);

        stopwatchNotifier.clearLaps();

        state = container.read(stopwatchNotifierProvider);

        expect(state.laps.length, 0);
      });
    });
  });
}
