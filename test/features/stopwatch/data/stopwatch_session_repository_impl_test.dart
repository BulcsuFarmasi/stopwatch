import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository_impl.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';
import 'package:stopwatch/features/stopwatch/model/stored_stopwatch_session.dart';

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

void main() {
  group("StopwatchSessionRepositoryImpl", () {
    late StopwatchSessionRepositoryImpl stopwatchSessionRepositoryImpl;
    late SharedPreferencesAsync sharedPreferencesAsync;

    setUp(() {
      sharedPreferencesAsync = MockSharedPreferencesAsync();
      stopwatchSessionRepositoryImpl = StopwatchSessionRepositoryImpl(
        sharedPreferencesAsync,
      );
    });

    group("clear", () {
      test("should call preferences remove with the correct key", () async {
        when(
          () => sharedPreferencesAsync.remove(
            StopwatchSessionRepositoryImpl.sharedPreferencesKey,
          ),
        ).thenAnswer((_) async {});
        await stopwatchSessionRepositoryImpl.clear();
        verify(
          () => sharedPreferencesAsync.remove(
            StopwatchSessionRepositoryImpl.sharedPreferencesKey,
          ),
        ).called(1);
      });
      test("should throw an exception if remove has failed", () async {
        when(
          () => sharedPreferencesAsync.remove(
            StopwatchSessionRepositoryImpl.sharedPreferencesKey,
          ),
        ).thenThrow(Exception());

        await expectLater(
          stopwatchSessionRepositoryImpl.clear(),
          throwsA(SessionIssue.clearFailed),
        );
      });
    });

    group("load", () {
      test("should load successfully the session", () async {
        final StoredStopwatchSession storedStopwatchSession =
            StoredStopwatchSession(
              elapsed: Duration.zero,
              savedAtUtc: DateTime.utc(2026, 9, 12),
              status: StopwatchStatus.running,
              laps: [],
            );

        when(
          () => sharedPreferencesAsync.getString(
            StopwatchSessionRepositoryImpl.sharedPreferencesKey,
          ),
        ).thenAnswer((_) async => json.encode(storedStopwatchSession.toJson()));

        final StoredStopwatchSession restoredSession =
            (await stopwatchSessionRepositoryImpl.load())!;

        expect(restoredSession.elapsed, Duration.zero);
        expect(restoredSession.savedAtUtc, DateTime.utc(2026, 9, 12));
        expect(restoredSession.status, StopwatchStatus.running);
        expect(restoredSession.laps, []);
        expect(restoredSession.schemaVersion, 1);
      });

      test("should throw a readFailed exception if exception read is not successful", () async {
        when(
          () => sharedPreferencesAsync.getString(
            StopwatchSessionRepositoryImpl.sharedPreferencesKey,
          ),
        ).thenThrow(Exception());

        await expectLater(
          stopwatchSessionRepositoryImpl.load(),
          throwsA(SessionIssue.readFailed),
        );
      });

      test("should return with null if session is not present", () async {
        when(
          () => sharedPreferencesAsync.getString(
            StopwatchSessionRepositoryImpl.sharedPreferencesKey,
          ),
        ).thenAnswer((_) async => null);

        final StoredStopwatchSession? restoredSession =
            (await stopwatchSessionRepositoryImpl.load());

        expect(restoredSession, isNull);
      });

      test("should throw invalidSavedSession if schema version is unsupported", () async {
        final StoredStopwatchSession storedStopwatchSession =
            StoredStopwatchSession(
              elapsed: Duration.zero,
              savedAtUtc: DateTime.utc(2026, 9, 12),
              status: StopwatchStatus.running,
              laps: [],
              schemaVersion: 100,
            );

        when(
          () => sharedPreferencesAsync.getString(
            StopwatchSessionRepositoryImpl.sharedPreferencesKey,
          ),
        ).thenAnswer((_) async => json.encode(storedStopwatchSession.toJson()));

        await expectLater(
          stopwatchSessionRepositoryImpl.load(),
          throwsA(SessionIssue.invalidSavedSession),
        );
      });
      test(
        "should throw invalidSavedSession if stored data is invalid",
        () async {
          final Map<String, dynamic> incorrectJson = {
            "elapsedMicroseconds": null,
            "savedAtMicroseconds": "1000",
            "status": "unknown",
            "schemaVersion": 1,
            "laps": null,
          };

          when(
            () => sharedPreferencesAsync.getString(
              StopwatchSessionRepositoryImpl.sharedPreferencesKey,
            ),
          ).thenAnswer((_) async => json.encode(incorrectJson));

          await expectLater(
            stopwatchSessionRepositoryImpl.load(),
            throwsA(SessionIssue.invalidSavedSession),
          );
        },
      );
      test(
        "should throw invalidSavedSession if a malformed json is stored",
        () async {
          when(
            () => sharedPreferencesAsync.getString(
              StopwatchSessionRepositoryImpl.sharedPreferencesKey,
            ),
          ).thenAnswer((_) async => "{malformed");

          await expectLater(
            stopwatchSessionRepositoryImpl.load(),
            throwsA(SessionIssue.invalidSavedSession),
          );
        },
      );
    });

    group("save", () {
      final StoredStopwatchSession storedStopwatchSession =
          StoredStopwatchSession(
            elapsed: Duration.zero,
            savedAtUtc: DateTime.utc(2026, 9, 12),
            status: StopwatchStatus.running,
            laps: [],
          );

      test(
        "should call preferences setString with the correct key and session",
        () async {
          when(
            () => sharedPreferencesAsync.setString(
              StopwatchSessionRepositoryImpl.sharedPreferencesKey,
              json.encode(storedStopwatchSession.toJson()),
            ),
          ).thenAnswer((_) async {});
          await stopwatchSessionRepositoryImpl.save(storedStopwatchSession);
          verify(
            () => sharedPreferencesAsync.setString(
              StopwatchSessionRepositoryImpl.sharedPreferencesKey,
              json.encode(storedStopwatchSession.toJson()),
            ),
          ).called(1);
        },
      );
      test("should throw an exception if save has failed", () async {
        when(
          () => sharedPreferencesAsync.setString(
            StopwatchSessionRepositoryImpl.sharedPreferencesKey,
            json.encode(storedStopwatchSession.toJson()),
          ),
        ).thenThrow(Exception());

        await expectLater(
          stopwatchSessionRepositoryImpl.save(storedStopwatchSession),
          throwsA(SessionIssue.saveFailed),
        );
      });
    });

    group("queue", () {
      test("should wait for a pending save before clearing", () async {
        final Completer<void> saveCompleter = Completer();

        when(() => sharedPreferencesAsync.setString(any(), any()))
            .thenAnswer((_) => saveCompleter.future);

        when(() => sharedPreferencesAsync.remove(any()))
            .thenAnswer((_) async {});

        final Future<void> saveFuture = stopwatchSessionRepositoryImpl.save(
          StoredStopwatchSession(
            elapsed: Duration.zero,
            savedAtUtc: DateTime.utc(2026, 9, 12),
            status: StopwatchStatus.running,
            laps: [],
          ),
        );
        final Future<void> clearFuture = stopwatchSessionRepositoryImpl.clear();

        await Future<void>.delayed(Duration.zero);

        verifyNever(() => sharedPreferencesAsync.remove(any()));

        saveCompleter.complete();

        await saveFuture;
        await clearFuture;

        verify(() => sharedPreferencesAsync.remove(any())).called(1);
      });

      test(
        'should continue processing operations after a failed save',
        () async {
          when(() => sharedPreferencesAsync.setString(any(), any()))
              .thenAnswer((_) async => throw Exception());

          when(() => sharedPreferencesAsync.remove(any()))
              .thenAnswer((_) async {});

          final Future<void> saveFuture = stopwatchSessionRepositoryImpl.save(
            StoredStopwatchSession(
              elapsed: Duration.zero,
              savedAtUtc: DateTime.utc(2026, 9, 12),
              status: StopwatchStatus.running,
              laps: [],
            ),
          );
          final Future<void> clearFuture = stopwatchSessionRepositoryImpl
              .clear();

          await expectLater(saveFuture, throwsA(SessionIssue.saveFailed));
          await clearFuture;

          verify(() => sharedPreferencesAsync.remove(any())).called(1);
        },
      );
    });
  });
}
