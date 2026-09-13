import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_session_coordinator.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_session.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';

class MockStopwatchService extends Mock implements StopwatchService {}

class MockStopwatchSessionCoordinator extends Mock
    implements StopwatchSessionCoordinator {}

void main() {
  group('StopwatchNotifier', () {
    late StopwatchService stopwatchService;
    late StopwatchSessionCoordinator stopwatchSessionCoordinator;
    late ProviderContainer container;
    late StopwatchNotifier stopwatchNotifier;
    const int elapsedMilliseconds = 32;
    setUpTest({StopwatchSession? restoredSession}) async {
      stopwatchService = MockStopwatchService();
      stopwatchSessionCoordinator = MockStopwatchSessionCoordinator();
      when(() => stopwatchSessionCoordinator.restore())
          .thenAnswer((_) async => restoredSession);

      container = ProviderContainer.test(
        overrides: [
          stopwatchServiceProvider.overrideWithValue(stopwatchService),
          stopwatchSessionCoordinatorProvider.overrideWithValue(
            stopwatchSessionCoordinator,
          ),
        ],
      );
      await container.read(stopwatchNotifierProvider.future);
      stopwatchNotifier = container.read(stopwatchNotifierProvider.notifier);
      registerFallbackValue(
        StopwatchSession(
          elapsed: Duration.zero,
          status: StopwatchStatus.initial,
          laps: [
            Lap(
              number: 1,
              total: Duration(milliseconds: elapsedMilliseconds),
              split: Duration(milliseconds: elapsedMilliseconds),
            ),
          ],
        ),
      );
    }

    void notifierStart() {
      when(() => stopwatchService.start()).thenReturn(null);
      when(() => stopwatchSessionCoordinator.save(any()))
          .thenAnswer((_) async {});
      stopwatchNotifier.start();
    }

    group('start', () {
      test('should start stopwatch, when calling start', () async {
        await setUpTest();
        fakeAsync((FakeAsync async) {
          notifierStart();

          when(() => stopwatchService.elapsedTime)
              .thenReturn(Duration(milliseconds: elapsedMilliseconds));

          stopwatchNotifier.startRefreshTimer();

          async.elapse(Duration(milliseconds: elapsedMilliseconds));

          final AsyncValue<StopwatchState> state = container.read(
            stopwatchNotifierProvider,
          );

          final StopwatchState current = state.requireValue;

          verify(() => stopwatchService.start()).called(1);
          expect(current.status, StopwatchStatus.running);

          expect(current.elapsed, Duration(milliseconds: elapsedMilliseconds));
        });
      });
      test(
        'multiple start call should not start the stopwatch multiple times',
        () async {
          await setUpTest();

          notifierStart();

          stopwatchNotifier.start();
          stopwatchNotifier.start();

          verify(() => stopwatchService.start()).called(1);
        },
      );
    });
    group('pause', () {
      test('should pause the stopwatch', () async {
        await setUpTest();
        fakeAsync((FakeAsync async) {
          notifierStart();

          when(() => stopwatchService.elapsedTime)
              .thenReturn(Duration(milliseconds: elapsedMilliseconds));

          stopwatchNotifier.startRefreshTimer();

          async.elapse(Duration(milliseconds: elapsedMilliseconds));

          AsyncValue<StopwatchState> state = container.read(
            stopwatchNotifierProvider,
          );

          StopwatchState current = state.requireValue;

          verify(() => stopwatchService.start()).called(1);
          expect(current.status, StopwatchStatus.running);
          expect(current.elapsed, Duration(milliseconds: elapsedMilliseconds));

          stopwatchNotifier.pause();
          async.elapse(Duration(milliseconds: elapsedMilliseconds));
          state = container.read(stopwatchNotifierProvider);

          current = state.requireValue;

          verify(() => stopwatchService.stop()).called(1);
          expect(current.status, StopwatchStatus.paused);
          expect(current.elapsed, Duration(milliseconds: elapsedMilliseconds));
        });
      });
    });

    group('reset', () {
      test(
        'should reset the stopwatch and clear elapsed time and laps',
        () async {
          await setUpTest();
          fakeAsync((FakeAsync async) {
            notifierStart();

            when(() => stopwatchService.elapsedTime)
                .thenReturn(Duration(milliseconds: elapsedMilliseconds));

            stopwatchNotifier.startRefreshTimer();

            async.elapse(Duration(milliseconds: elapsedMilliseconds));

            stopwatchNotifier.recordLap();

            AsyncValue<StopwatchState> state = container.read(
              stopwatchNotifierProvider,
            );

            StopwatchState current = state.requireValue;

            verify(() => stopwatchService.start()).called(1);
            expect(current.status, StopwatchStatus.running);
            expect(
              current.elapsed,
              Duration(milliseconds: elapsedMilliseconds),
            );
            expect(current.laps.length, 1);

            when(() => stopwatchSessionCoordinator.clear())
                .thenAnswer((_) async {});

            stopwatchNotifier.reset();
            async.elapse(Duration(milliseconds: elapsedMilliseconds));
            state = container.read(stopwatchNotifierProvider);
            current = state.requireValue;

            verify(() => stopwatchService.reset()).called(1);
            expect(current.status, StopwatchStatus.initial);
            expect(current.elapsed, Duration.zero);
            expect(current.laps.length, 0);
          });
        },
      );
    });
    group('recordLap', () {
      test('should register the first lap', () async {
        await setUpTest();

        notifierStart();

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds));

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

      test('should register another lap', () async {
        await setUpTest();

        notifierStart();

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds));

        stopwatchNotifier.recordLap();

        AsyncValue<StopwatchState> state = container.read(
          stopwatchNotifierProvider,
        );
        StopwatchState current = state.requireValue;

        expect(current.laps.length, 1);

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds * 2));

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

      test(
        'should not record lap while stopwatch is not yet running',
        () async {
          await setUpTest();

          AsyncValue<StopwatchState> state = container.read(
            stopwatchNotifierProvider,
          );
          StopwatchState current = state.requireValue;

          expect(current.laps, isEmpty);

          stopwatchNotifier.recordLap();

          state = container.read(stopwatchNotifierProvider);
          current = state.requireValue;

          expect(current.laps, isEmpty);
        },
      );

      test('should not record lap while stopwatch is paused', () async {
        await setUpTest();

        notifierStart();

        AsyncValue<StopwatchState> state = container.read(
          stopwatchNotifierProvider,
        );
        StopwatchState current = state.requireValue;

        expect(current.laps, isEmpty);

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds));

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
      test('should clear the laps', () async {
        await setUpTest();

        notifierStart();

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds));

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
