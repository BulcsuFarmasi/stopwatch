import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_notifier.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_refresh_scheduler.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_session_coordinator.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_session.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';

class MockStopwatchService extends Mock implements StopwatchService {}

class MockStopwatchSessionCoordinator extends Mock
    implements StopwatchSessionCoordinator {}

class MockStopwatchRefreshScheduler extends Mock
    implements StopwatchRefreshScheduler {}

void main() {
  group('StopwatchNotifier', () {
    late StopwatchService stopwatchService;
    late StopwatchSessionCoordinator stopwatchSessionCoordinator;
    late StopwatchRefreshScheduler stopwatchRefreshScheduler;
    late ProviderContainer container;
    late StopwatchNotifier stopwatchNotifier;
    const int elapsedMilliseconds = 32;

    setUpAll(() {
      registerFallbackValue(
        StopwatchSession(
          elapsed: Duration.zero,
          status: StopwatchStatus.initial,
          laps: [],
        ),
      );
      registerFallbackValue(() {});
    });

    Future<void> setUpTest({
      StopwatchSession? restoredSession,
      SessionIssue? sessionIssue,
    }) async {
      stopwatchService = MockStopwatchService();
      stopwatchSessionCoordinator = MockStopwatchSessionCoordinator();
      stopwatchRefreshScheduler = MockStopwatchRefreshScheduler();

      if (restoredSession != null) {
        when(() => stopwatchSessionCoordinator.restore())
            .thenAnswer((_) async => restoredSession);
      } else if (sessionIssue != null) {
        when(() => stopwatchSessionCoordinator.restore())
            .thenThrow(sessionIssue);
      } else {
        when(() => stopwatchSessionCoordinator.restore())
            .thenAnswer((_) async => null);
      }

      container = ProviderContainer.test(
        overrides: [
          stopwatchServiceProvider.overrideWithValue(stopwatchService),
          stopwatchSessionCoordinatorProvider.overrideWithValue(
            stopwatchSessionCoordinator,
          ),
          stopwatchRefreshSchedulerProvider.overrideWithValue(
            stopwatchRefreshScheduler,
          ),
        ],
      );
      await container.read(stopwatchNotifierProvider.future);
      stopwatchNotifier = container.read(stopwatchNotifierProvider.notifier);
    }

    group("build", () {
      test("should create an initial state if session is null", () async {
        await setUpTest();

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;

        expect(state.elapsed, Duration.zero);
        expect(state.status, StopwatchStatus.initial);
        expect(state.laps, []);
        expect(state.isSessionOperationInProgress, false);
        expect(state.sessionIssue, null);
      });

      test("should restore elapsed time if session is not null", () async {
        await setUpTest(
          restoredSession: StopwatchSession(
            elapsed: Duration(milliseconds: elapsedMilliseconds),
            status: StopwatchStatus.running,
            laps: [
              Lap(
                number: 1,
                split: Duration(milliseconds: 20),
                total: Duration(milliseconds: 20),
              ),
            ],
          ),
        );

        verify(
          () => stopwatchService.restoreElapsed(
            Duration(milliseconds: elapsedMilliseconds),
          ),
        ).called(1);
      });

      test("should initialize a state with running session and start stopwatch and scheduler", () async {
        await setUpTest(
          restoredSession: StopwatchSession(
            elapsed: Duration(milliseconds: elapsedMilliseconds),
            status: StopwatchStatus.running,
            laps: [
              Lap(
                number: 1,
                split: Duration(milliseconds: 20),
                total: Duration(milliseconds: 20),
              ),
            ],
          ),
        );

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;

        expect(state.elapsed, Duration(milliseconds: elapsedMilliseconds));
        expect(state.status, StopwatchStatus.running);
        expect(state.laps, [
          Lap(
            number: 1,
            split: Duration(milliseconds: 20),
            total: Duration(milliseconds: 20),
          ),
        ]);
        expect(state.isSessionOperationInProgress, false);

        verify(() => stopwatchService.start()).called(1);

        verify(() => stopwatchRefreshScheduler.startTimer(any())).called(1);
      });

      test("should initialize a state with paused session and don't start stopwatch and scheduler", () async {
        await setUpTest(
          restoredSession: StopwatchSession(
            elapsed: Duration(milliseconds: elapsedMilliseconds),
            status: StopwatchStatus.paused,
            laps: [
              Lap(
                number: 1,
                split: Duration(milliseconds: 20),
                total: Duration(milliseconds: 20),
              ),
            ],
          ),
        );

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;

        expect(state.elapsed, Duration(milliseconds: elapsedMilliseconds));
        expect(state.status, StopwatchStatus.paused);
        expect(state.laps, [
          Lap(
            number: 1,
            split: Duration(milliseconds: 20),
            total: Duration(milliseconds: 20),
          ),
        ]);
        expect(state.isSessionOperationInProgress, false);
        verifyNever(() => stopwatchService.start());
        verifyNever(() => stopwatchRefreshScheduler.startTimer(any()));
      });

      for (SessionIssue issue in [
        SessionIssue.invalidSavedSession,
        SessionIssue.readFailed,
        SessionIssue.clearFailed,
      ]) {
        test("should return with $issue if that is thrown", () async {
          await setUpTest(sessionIssue: issue);

          final StopwatchState state = container
              .read(stopwatchNotifierProvider)
              .requireValue;

          expect(state.sessionIssue, issue);
        });
      }
    });

    group('start', () {
      test('should start stopwatch, when calling start', () async {
        await setUpTest();
        when(() => stopwatchService.start()).thenReturn(null);
        when(() => stopwatchSessionCoordinator.save(any()))
            .thenAnswer((_) async {});
        stopwatchNotifier.start();

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds));

        final VoidCallback onUpdate =
            verify(() => stopwatchRefreshScheduler.startTimer(captureAny()))
                    .captured
                    .single
                as VoidCallback;

        onUpdate();

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;

        verify(() => stopwatchService.start()).called(1);
        expect(state.status, StopwatchStatus.running);

        expect(state.elapsed, Duration(milliseconds: elapsedMilliseconds));

        final StopwatchSession saved =
            verify(() => stopwatchSessionCoordinator.save(captureAny()))
                    .captured
                    .single
                as StopwatchSession;
        expect(saved.status, StopwatchStatus.running);
        expect(saved.elapsed, Duration.zero);
        expect(saved.laps, isEmpty);
      });
      test(
        'multiple start call should not start the stopwatch multiple times',
        () async {
          await setUpTest();

          when(() => stopwatchService.start()).thenReturn(null);
          when(() => stopwatchSessionCoordinator.save(any()))
              .thenAnswer((_) async {});
          stopwatchNotifier.start();

          stopwatchNotifier.start();
          stopwatchNotifier.start();

          verify(() => stopwatchService.start()).called(1);
        },
      );

      test('reports a failed save and clears the issue on success', () async {
        await setUpTest();
        when(() => stopwatchSessionCoordinator.save(any()))
            .thenThrow(SessionIssue.saveFailed);

        stopwatchNotifier.start();
        await Future<void>.delayed(Duration.zero);

        StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;
        expect(state.status, StopwatchStatus.running);
        expect(state.sessionIssue, SessionIssue.saveFailed);

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds));
        when(() => stopwatchSessionCoordinator.save(any()))
            .thenAnswer((_) async {});
        stopwatchNotifier.pause();
        await Future<void>.delayed(Duration.zero);

        state = container.read(stopwatchNotifierProvider).requireValue;
        verify(() => stopwatchSessionCoordinator.save(any())).called(2);
        expect(state.status, StopwatchStatus.paused);
        expect(state.sessionIssue, isNull);
      });
    });

    group('startRefresh', () {
      test(
        'enables refresh without scheduling a timer while initial',
        () async {
          await setUpTest();

          stopwatchNotifier.startRefresh();

          verify(() => stopwatchRefreshScheduler.startRefresh()).called(1);
          verifyNever(() => stopwatchRefreshScheduler.startTimer(any()));
        },
      );

      test('enables refresh without scheduling a timer while paused', () async {
        await setUpTest(
          restoredSession: StopwatchSession(
            elapsed: Duration(milliseconds: elapsedMilliseconds),
            status: StopwatchStatus.paused,
            laps: [],
          ),
        );

        stopwatchNotifier.startRefresh();

        verify(() => stopwatchRefreshScheduler.startRefresh()).called(1);
        verifyNever(() => stopwatchRefreshScheduler.startTimer(any()));
      });

      test('refreshes immediately and on a tick while running', () async {
        await setUpTest(
          restoredSession: StopwatchSession(
            elapsed: Duration(milliseconds: elapsedMilliseconds),
            status: StopwatchStatus.running,
            laps: [],
          ),
        );
        // Ignore the scheduling request made during restoration.
        verify(() => stopwatchRefreshScheduler.startTimer(any())).called(1);
        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds * 2));

        stopwatchNotifier.startRefresh();

        verify(() => stopwatchRefreshScheduler.startRefresh()).called(1);
        final VoidCallback onTick =
            verify(() => stopwatchRefreshScheduler.startTimer(captureAny()))
                    .captured
                    .single
                as VoidCallback;
        expect(
          container.read(stopwatchNotifierProvider).requireValue.elapsed,
          Duration(milliseconds: elapsedMilliseconds * 2),
        );

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds * 3));
        onTick();
        expect(
          container.read(stopwatchNotifierProvider).requireValue.elapsed,
          Duration(milliseconds: elapsedMilliseconds * 3),
        );
      });
    });

    group('pause', () {
      test('should pause the stopwatch', () async {
        await setUpTest(
          restoredSession: StopwatchSession(
            elapsed: Duration(milliseconds: elapsedMilliseconds),
            status: StopwatchStatus.running,
            laps: [],
          ),
        );

        when(() => stopwatchSessionCoordinator.save(any()))
            .thenAnswer((_) async {});

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds));

        stopwatchNotifier.pause();

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;

        verify(() => stopwatchService.stop()).called(1);
        verify(() => stopwatchRefreshScheduler.stopTimer()).called(1);
        expect(state.status, StopwatchStatus.paused);
        expect(state.elapsed, Duration(milliseconds: elapsedMilliseconds));

        final StopwatchSession saved =
            verify(() => stopwatchSessionCoordinator.save(captureAny()))
                    .captured
                    .single
                as StopwatchSession;
        expect(saved.status, StopwatchStatus.paused);
        expect(saved.elapsed, Duration(milliseconds: elapsedMilliseconds));
        expect(saved.laps, isEmpty);
      });
    });

    group('reset', () {
      test(
        'should reset the stopwatch and clear elapsed time and laps',
        () async {
          await setUpTest(
            restoredSession: StopwatchSession(
              elapsed: Duration(milliseconds: elapsedMilliseconds),
              status: StopwatchStatus.running,
              laps: [
                Lap(
                  number: 1,
                  split: Duration(milliseconds: 20),
                  total: Duration(milliseconds: 20),
                ),
              ],
            ),
          );

          when(() => stopwatchSessionCoordinator.clear())
              .thenAnswer((_) async {});

          await stopwatchNotifier.reset();

          final StopwatchState state = container
              .read(stopwatchNotifierProvider)
              .requireValue;

          verify(() => stopwatchService.reset()).called(1);
          verify(() => stopwatchRefreshScheduler.stopTimer()).called(1);
          verify(() => stopwatchSessionCoordinator.clear()).called(1);
          expect(state.status, StopwatchStatus.initial);
          expect(state.elapsed, Duration.zero);
          expect(state.laps.length, 0);
        },
      );
    });

    group("stopRefresh", () {
      test('stops refresh and the active timer when hidden', () async {
        await setUpTest();

        stopwatchNotifier.stopRefresh();

        verify(() => stopwatchRefreshScheduler.stopRefresh()).called(1);
        verify(() => stopwatchRefreshScheduler.stopTimer()).called(1);
      });
    });

    group('recordLap', () {
      test('should register the first lap', () async {
        await setUpTest(
          restoredSession: StopwatchSession(
            elapsed: Duration.zero,
            status: StopwatchStatus.running,
            laps: [],
          ),
        );

        when(() => stopwatchSessionCoordinator.save(any()))
            .thenAnswer((_) async {});

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds));

        stopwatchNotifier.recordLap();

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;

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
        expect(state.elapsed, Duration(milliseconds: elapsedMilliseconds));
        final StopwatchSession saved =
            verify(() => stopwatchSessionCoordinator.save(captureAny()))
                    .captured
                    .single
                as StopwatchSession;
        expect(saved.status, StopwatchStatus.running);
        expect(saved.elapsed, Duration(milliseconds: elapsedMilliseconds));
        expect(saved.laps, state.laps);
      });

      test('should register another lap', () async {
        await setUpTest(
          restoredSession: StopwatchSession(
            elapsed: Duration(milliseconds: elapsedMilliseconds),
            status: StopwatchStatus.running,
            laps: [
              Lap(
                number: 1,
                split: Duration(milliseconds: elapsedMilliseconds),
                total: Duration(milliseconds: elapsedMilliseconds),
              ),
            ],
          ),
        );

        when(() => stopwatchSessionCoordinator.save(any()))
            .thenAnswer((_) async {});

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: elapsedMilliseconds * 2));

        stopwatchNotifier.recordLap();

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;

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
        final StopwatchSession saved =
            verify(() => stopwatchSessionCoordinator.save(captureAny()))
                    .captured
                    .single
                as StopwatchSession;
        expect(saved.elapsed, Duration(milliseconds: elapsedMilliseconds * 2));
        expect(saved.laps, state.laps);
      });

      test(
        'should not record lap while stopwatch is not yet running',
        () async {
          await setUpTest();

          stopwatchNotifier.recordLap();

          final StopwatchState state = container
              .read(stopwatchNotifierProvider)
              .requireValue;

          expect(state.laps, isEmpty);
        },
      );

      test('should not record lap while stopwatch is paused', () async {
        await setUpTest(
          restoredSession: StopwatchSession(
            elapsed: Duration(milliseconds: elapsedMilliseconds),
            status: StopwatchStatus.paused,
            laps: [],
          ),
        );

        stopwatchNotifier.recordLap();

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;

        expect(state.laps, isEmpty);
      });
    });
    group('clear laps', () {
      test('should clear the laps', () async {
        await setUpTest(
          restoredSession: StopwatchSession(
            elapsed: Duration(milliseconds: elapsedMilliseconds),
            status: StopwatchStatus.running,
            laps: [
              Lap(
                number: 1,
                split: Duration(milliseconds: 20),
                total: Duration(milliseconds: 20),
              ),
            ],
          ),
        );

        when(() => stopwatchSessionCoordinator.save(any()))
            .thenAnswer((_) async {});

        when(() => stopwatchService.elapsedTime)
            .thenReturn(Duration(milliseconds: 40));

        stopwatchNotifier.clearLaps();

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;

        expect(state.laps.length, 0);
        expect(state.elapsed, Duration(milliseconds: 40));
        final StopwatchSession saved =
            verify(() => stopwatchSessionCoordinator.save(captureAny()))
                    .captured
                    .single
                as StopwatchSession;
        expect(saved.status, StopwatchStatus.running);
        expect(saved.elapsed, Duration(milliseconds: 40));
        expect(saved.laps, isEmpty);
      });
    });

    group('retrySessionRestore', () {
      test('restores a session after a read failure', () async {
        await setUpTest(sessionIssue: SessionIssue.readFailed);
        when(() => stopwatchSessionCoordinator.restore()).thenAnswer(
          (_) async => StopwatchSession(
            elapsed: Duration(milliseconds: elapsedMilliseconds),
            status: StopwatchStatus.paused,
            laps: [],
          ),
        );

        await stopwatchNotifier.retrySessionRestore();

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;
        verify(() => stopwatchSessionCoordinator.restore()).called(2);
        verify(() => stopwatchService.restoreElapsed(state.elapsed)).called(1);
        expect(state.status, StopwatchStatus.paused);
        expect(state.elapsed, Duration(milliseconds: elapsedMilliseconds));
        expect(state.sessionIssue, isNull);
        expect(state.isSessionOperationInProgress, isFalse);
      });

      test('keeps the issue when retrying restoration fails again', () async {
        await setUpTest(sessionIssue: SessionIssue.readFailed);

        await stopwatchNotifier.retrySessionRestore();

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;
        verify(() => stopwatchSessionCoordinator.restore()).called(2);
        expect(state.sessionIssue, SessionIssue.readFailed);
        expect(state.isSessionOperationInProgress, isFalse);
      });
    });

    group("clearSavedSession", () {
      test('discard clears a failed session and unblocks actions', () async {
        await setUpTest(sessionIssue: SessionIssue.readFailed);
        when(() => stopwatchSessionCoordinator.clear())
            .thenAnswer((_) async {});

        await stopwatchNotifier.clearSavedSession();

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;
        verify(() => stopwatchSessionCoordinator.clear()).called(1);
        expect(state.status, StopwatchStatus.initial);
        expect(state.sessionIssue, isNull);
        expect(state.areStopwatchActionsBlocked, isFalse);
      });

      test('a failed clear can be retried', () async {
        await setUpTest(sessionIssue: SessionIssue.readFailed);
        when(() => stopwatchSessionCoordinator.clear())
            .thenThrow(SessionIssue.clearFailed);

        await stopwatchNotifier.clearSavedSession();

        StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;
        expect(state.sessionIssue, SessionIssue.clearFailed);
        expect(state.areStopwatchActionsBlocked, isTrue);
        expect(state.isSessionOperationInProgress, isFalse);

        when(() => stopwatchSessionCoordinator.clear())
            .thenAnswer((_) async {});
        await stopwatchNotifier.clearSavedSession();

        state = container.read(stopwatchNotifierProvider).requireValue;
        verify(() => stopwatchSessionCoordinator.clear()).called(2);
        expect(state.sessionIssue, isNull);
        expect(state.areStopwatchActionsBlocked, isFalse);
      });

      test('blocks stopwatch actions while clearing a session', () async {
        await setUpTest(
          restoredSession: StopwatchSession(
            elapsed: Duration(milliseconds: elapsedMilliseconds),
            status: StopwatchStatus.running,
            laps: [],
          ),
        );
        final Completer<void> clearCompleter = Completer<void>();
        when(() => stopwatchSessionCoordinator.clear())
            .thenAnswer((_) => clearCompleter.future);

        final Future<void> clearing = stopwatchNotifier.clearSavedSession();
        expect(
          container
              .read(stopwatchNotifierProvider)
              .requireValue
              .isSessionOperationInProgress,
          isTrue,
        );

        stopwatchNotifier.pause();
        stopwatchNotifier.recordLap();
        await stopwatchNotifier.reset();
        verifyNever(() => stopwatchService.stop());
        verifyNever(() => stopwatchService.reset());
        verifyNever(() => stopwatchSessionCoordinator.save(any()));

        clearCompleter.complete();
        await clearing;
        expect(
          container
              .read(stopwatchNotifierProvider)
              .requireValue
              .isSessionOperationInProgress,
          isFalse,
        );
      });
    });

    group("clearSavedSession", () {
      test('acknowledging an invalid session clears its issue', () async {
        await setUpTest(sessionIssue: SessionIssue.invalidSavedSession);

        stopwatchNotifier.acknowledgeInvalidSavedSession();

        final StopwatchState state = container
            .read(stopwatchNotifierProvider)
            .requireValue;
        expect(state.status, StopwatchStatus.initial);
        expect(state.sessionIssue, isNull);
      });
    });
  });
}
