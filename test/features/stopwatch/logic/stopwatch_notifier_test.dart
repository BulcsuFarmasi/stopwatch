import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';
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

          final AsyncValue<StopwatchState> state = container.read(
            stopwatchNotifierProvider,
          );

          final StopwatchState current = state.requireValue;

          expect(fakeStopwatchService.startCalls, 1);
          expect(fakeStopwatchService.isRunning, true);
          expect(current.status, StopwatchStatus.running);
          expect(current.elapsed, Duration(milliseconds: elapsedMilliseconds));
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

          AsyncValue<StopwatchState> state = container.read(
            stopwatchNotifierProvider,
          );

          StopwatchState current = state.requireValue;

          expect(fakeStopwatchService.startCalls, 1);
          expect(fakeStopwatchService.isRunning, true);
          expect(current.status, StopwatchStatus.running);
          expect(current.elapsed, Duration(milliseconds: elapsedMilliseconds));

          stopwatchNotifier.pause();
          async.elapse(Duration(milliseconds: elapsedMilliseconds));
          state = container.read(stopwatchNotifierProvider);

          current = state.requireValue;

          expect(fakeStopwatchService.stopCalls, 1);
          expect(current.status, StopwatchStatus.paused);
          expect(fakeStopwatchService.isRunning, false);
          expect(current.elapsed, Duration(milliseconds: elapsedMilliseconds));
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

          AsyncValue<StopwatchState> state = container.read(
            stopwatchNotifierProvider,
          );

          StopwatchState current = state.requireValue;

          expect(fakeStopwatchService.startCalls, 1);
          expect(fakeStopwatchService.isRunning, true);
          expect(current.status, StopwatchStatus.running);
          expect(current.elapsed, Duration(milliseconds: elapsedMilliseconds));
          expect(current.laps.length, 1);

          stopwatchNotifier.reset();
          async.elapse(Duration(milliseconds: elapsedMilliseconds));
          state = container.read(stopwatchNotifierProvider);
          current = state.requireValue;

          expect(fakeStopwatchService.resetCalls, 1);
          expect(current.status, StopwatchStatus.initial);
          expect(fakeStopwatchService.isRunning, false);
          expect(current.elapsed, Duration.zero);
          expect(current.laps.length, 0);
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

        final AsyncValue<StopwatchState> state = container.read(
          stopwatchNotifierProvider,
        );
        final StopwatchState current = state.requireValue;

        expect(current.laps.length, 1);
        expect(current.laps.first.number, 1);
        expect(
          current.laps.first.total,
          Duration(milliseconds: elapsedMilliseconds),
        );
        expect(
          current.laps.first.split,
          Duration(milliseconds: elapsedMilliseconds),
        );
      });

      test('should register another lap', () {
        stopwatchNotifier.start();
        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        stopwatchNotifier.recordLap();

        AsyncValue<StopwatchState> state = container.read(
          stopwatchNotifierProvider,
        );
        StopwatchState current = state.requireValue;

        expect(current.laps.length, 1);

        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        stopwatchNotifier.recordLap();

        state = container.read(stopwatchNotifierProvider);
        current = state.requireValue;

        expect(current.laps.length, 2);
        expect(current.laps.first.number, 2);
        expect(
          current.laps.first.total,
          Duration(milliseconds: elapsedMilliseconds) * 2,
        );
        expect(
          current.laps.first.split,
          Duration(milliseconds: elapsedMilliseconds),
        );
      });

      test('should not record lap while stopwatch is not yet running', () {
        AsyncValue<StopwatchState> state = container.read(
          stopwatchNotifierProvider,
        );
        StopwatchState current = state.requireValue;

        expect(current.laps, isEmpty);

        stopwatchNotifier.recordLap();

        state = container.read(stopwatchNotifierProvider);
        current = state.requireValue;

        expect(current.laps, isEmpty);
      });

      test('should not record lap while stopwatch is paused', () {
        stopwatchNotifier.start();
        AsyncValue<StopwatchState> state = container.read(
          stopwatchNotifierProvider,
        );
        StopwatchState current = state.requireValue;

        expect(current.laps, isEmpty);

        stopwatchNotifier.pause();

        state = container.read(stopwatchNotifierProvider);
        current = state.requireValue;

        expect(current.laps, isEmpty);

        stopwatchNotifier.recordLap();

        state = container.read(stopwatchNotifierProvider);
        current = state.requireValue;

        expect(current.laps, isEmpty);
      });
    });
    group('clear laps', () {
      test('should clear the laps', () {
        stopwatchNotifier.start();
        fakeStopwatchService.advance(
          Duration(milliseconds: elapsedMilliseconds),
        );

        stopwatchNotifier.recordLap();

        AsyncValue<StopwatchState> state = container.read(
          stopwatchNotifierProvider,
        );
        StopwatchState current = state.requireValue;

        expect(current.laps.length, 1);

        stopwatchNotifier.clearLaps();

        state = container.read(stopwatchNotifierProvider);
        current = state.requireValue;

        expect(current.laps.length, 0);
      });
    });
  });
}
