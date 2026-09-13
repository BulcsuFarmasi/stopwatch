import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_session_coordinator.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_session.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';
import 'package:stopwatch/features/stopwatch/model/stored_stopwatch_session.dart';

class MockStopwatchSessionRepository extends Mock
    implements StopwatchSessionRepository {}

void main() {
  group("StopwatchSessionCoordinator", () {
    late StopwatchSessionRepository stopwatchSessionRepository;
    late StopwatchSessionCoordinator stopwatchSessionCoordinator;

    setUp(() {
      stopwatchSessionRepository = MockStopwatchSessionRepository();
      stopwatchSessionCoordinator = StopwatchSessionCoordinator(
        stopwatchSessionRepository: stopwatchSessionRepository,
        currentTime: () => DateTime.utc(2026, 9, 12),
      );
    });

    group("clear", () {
      test("should call repository's clear method", () async {
        when(() => stopwatchSessionRepository.clear()).thenAnswer((_) async {});

        await stopwatchSessionCoordinator.clear();

        verify(() => stopwatchSessionRepository.clear()).called(1);
      });

      test("should rethrow clearFailed session issue", () async {
        const SessionIssue sessionIssue = SessionIssue.clearFailed;
        when(() => stopwatchSessionRepository.clear()).thenThrow(sessionIssue);

        await expectLater(
          stopwatchSessionCoordinator.clear(),
          throwsA(sessionIssue),
        );
      });
    });

    group("restore", () {
      test("should return null if restored session is null", () async {
        when(() => stopwatchSessionRepository.load())
            .thenAnswer((_) async => null);

        await expectLater(await stopwatchSessionCoordinator.restore(), isNull);
      });

      test(
        "should return null if restored session has initial status",
        () async {
          when(() => stopwatchSessionRepository.load()).thenAnswer(
            (_) async => StoredStopwatchSession(
              elapsed: Duration.zero,
              savedAtUtc: DateTime.utc(2026, 9, 12),
              status: StopwatchStatus.initial,
              laps: [],
            ),
          );

          await expectLater(
            await stopwatchSessionCoordinator.restore(),
            isNull,
          );
        },
      );

      test("should return time with session with increased time  if restored session has running status", () async {
        when(() => stopwatchSessionRepository.load()).thenAnswer(
          (_) async => StoredStopwatchSession(
            elapsed: Duration(hours: 1),
            savedAtUtc: DateTime.utc(2026, 9, 11, 23),
            status: StopwatchStatus.running,
            laps: [
              Lap(
                number: 1,
                split: Duration(milliseconds: 50),
                total: Duration(milliseconds: 50),
              ),
            ],
          ),
        );

        StopwatchSession stopwatchSession = (await stopwatchSessionCoordinator
            .restore())!;

        expect(stopwatchSession.elapsed, Duration(hours: 2));
        expect(stopwatchSession.status, StopwatchStatus.running);
        expect(stopwatchSession.laps, [
          Lap(
            number: 1,
            split: Duration(milliseconds: 50),
            total: Duration(milliseconds: 50),
          ),
        ]);
      });

      test("should return time with session with not increased time  if restored session has paused status", () async {
        when(() => stopwatchSessionRepository.load()).thenAnswer(
          (_) async => StoredStopwatchSession(
            elapsed: Duration(hours: 1),
            savedAtUtc: DateTime.utc(2026, 9, 11, 23),
            status: StopwatchStatus.paused,
            laps: [
              Lap(
                number: 1,
                split: Duration(milliseconds: 50),
                total: Duration(milliseconds: 50),
              ),
            ],
          ),
        );

        StopwatchSession stopwatchSession = (await stopwatchSessionCoordinator
            .restore())!;

        expect(stopwatchSession.elapsed, Duration(hours: 1));
        expect(stopwatchSession.status, StopwatchStatus.paused);
        expect(stopwatchSession.laps, [
          Lap(
            number: 1,
            split: Duration(milliseconds: 50),
            total: Duration(milliseconds: 50),
          ),
        ]);
      });

      test("should rethrow invalidSaveSession session issue", () async {
        const SessionIssue sessionIssue = SessionIssue.invalidSavedSession;
        when(() => stopwatchSessionRepository.load()).thenThrow(sessionIssue);
        when(() => stopwatchSessionRepository.clear()).thenAnswer((_) async {});

        await expectLater(
          stopwatchSessionCoordinator.restore(),
          throwsA(sessionIssue),
        );
      });

      test("should call repository clear method when session issue is invalidSessionIssue", () async {
        const SessionIssue sessionIssue = SessionIssue.invalidSavedSession;
        when(() => stopwatchSessionRepository.load()).thenThrow(sessionIssue);
        when(() => stopwatchSessionRepository.clear()).thenAnswer((_) async {});

        await expectLater(
          stopwatchSessionCoordinator.restore(),
          throwsA(sessionIssue),
        );

        verify(() => stopwatchSessionRepository.clear()).called(1);
      });

      test("should rethrow readFailed session issue", () async {
        const SessionIssue sessionIssue = SessionIssue.readFailed;
        when(() => stopwatchSessionRepository.load()).thenThrow(sessionIssue);

        await expectLater(
          stopwatchSessionCoordinator.restore(),
          throwsA(sessionIssue),
        );
      });

      test("should not call repository clear method when session issue is readFailed", () async {
        const SessionIssue sessionIssue = SessionIssue.readFailed;
        when(() => stopwatchSessionRepository.load()).thenThrow(sessionIssue);
        when(() => stopwatchSessionRepository.clear()).thenAnswer((_) async {});

        await expectLater(
          stopwatchSessionCoordinator.restore(),
          throwsA(sessionIssue),
        );

        verifyNever(() => stopwatchSessionRepository.clear());
      });

      test("should throw clearFailed when restore issue is invalidSavedSession and clear issue is clearFailed", () async {
        const SessionIssue sessionIssue = SessionIssue.clearFailed;
        when(() => stopwatchSessionRepository.load())
            .thenThrow(SessionIssue.invalidSavedSession);
        when(() => stopwatchSessionRepository.clear()).thenThrow(sessionIssue);

        await expectLater(
          stopwatchSessionCoordinator.restore(),
          throwsA(sessionIssue),
        );
      });

      test(
        "should return the whole elapsed time if the clock is set backward",
        () async {
          when(() => stopwatchSessionRepository.load()).thenAnswer(
            (_) async => StoredStopwatchSession(
              elapsed: Duration(minutes: 10),
              savedAtUtc: DateTime.utc(2026, 9, 12, 0, 5),
              status: StopwatchStatus.running,
              laps: [
                Lap(
                  number: 1,
                  split: Duration(milliseconds: 50),
                  total: Duration(milliseconds: 50),
                ),
              ],
            ),
          );

          StopwatchSession stopwatchSession = (await stopwatchSessionCoordinator
              .restore())!;

          expect(stopwatchSession.elapsed, Duration(minutes: 10));
        },
      );
    });

    group("save", () {
      setUpAll(() {
        registerFallbackValue(
          StoredStopwatchSession(
            elapsed: Duration(hours: 1),
            savedAtUtc: DateTime.utc(2026, 9, 11, 23),
            status: StopwatchStatus.running,
            laps: [
              Lap(
                number: 1,
                split: Duration(milliseconds: 50),
                total: Duration(milliseconds: 50),
              ),
            ],
          ),
        );
      });

      test(
        "should call repository's save method with StoredStopwatchSession",
        () async {
          when(() => stopwatchSessionRepository.save(any()))
              .thenAnswer((_) async {});

          final StopwatchSession stopwatchSession = StopwatchSession(
            elapsed: Duration(hours: 1),
            status: StopwatchStatus.running,
            laps: [
              Lap(
                number: 1,
                split: Duration(milliseconds: 50),
                total: Duration(milliseconds: 50),
              ),
            ],
          );

          await stopwatchSessionCoordinator.save(stopwatchSession);

          final StoredStopwatchSession storedStopwatchSession =
              verify(() => stopwatchSessionRepository.save(captureAny()))
                      .captured
                      .single
                  as StoredStopwatchSession;

          expect(storedStopwatchSession.elapsed, stopwatchSession.elapsed);
          expect(storedStopwatchSession.status, stopwatchSession.status);
          expect(storedStopwatchSession.savedAtUtc, DateTime.utc(2026, 9, 12));
          expect(storedStopwatchSession.schemaVersion, 1);
          expect(storedStopwatchSession.laps, stopwatchSession.laps);
        },
      );

      test("should rethrow saveFailed session issue", () async {
        const SessionIssue sessionIssue = SessionIssue.saveFailed;
        when(() => stopwatchSessionRepository.save(any()))
            .thenThrow(sessionIssue);

        await expectLater(
          stopwatchSessionCoordinator.save(
            StopwatchSession(
              elapsed: Duration(hours: 1),
              status: StopwatchStatus.running,
              laps: [
                Lap(
                  number: 1,
                  split: Duration(milliseconds: 50),
                  total: Duration(milliseconds: 50),
                ),
              ],
            ),
          ),
          throwsA(sessionIssue),
        );
      });
    });
  });
}
