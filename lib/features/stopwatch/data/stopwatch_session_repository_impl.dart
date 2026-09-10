import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/model/stored_stopwatch_session.dart';

final Provider<StopwatchSessionRepository> stopwatchSessionRepositoryProvider =
    Provider<StopwatchSessionRepository>(
      (_) => StopwatchSessionRepositoryImpl(),
    );

class StopwatchSessionRepositoryImpl extends StopwatchSessionRepository {
  static const _sharedPreferencesKey = "stopwatchSession";

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  Future<void> _pendingWrite = Future.value();

  @override
  Future<void> clear() =>
      _enqueue(() => _preferences.remove(_sharedPreferencesKey));

  @override
  Future<StoredStopwatchSession?> load() async {
    String? sessionEncoded;

    try {
      sessionEncoded = await _preferences.getString(_sharedPreferencesKey);
    } catch (e) {
      // Future integration: report the original exception and stack trace
      // to Sentry or Firebase Crashlytics before translating it to SessionIssue.
      throw SessionIssue.readFailed;
    }

    if (sessionEncoded == null) {
      return null;
    }

    try {
      Map<String, dynamic> sessionJson = json.decode(sessionEncoded);

      sessionJson = _migrateIfNeeded(sessionJson);

      return StoredStopwatchSession.fromJson(sessionJson);
    } catch (_) {
      // Future integration: report the original exception and stack trace
      // to Sentry or Firebase Crashlytics before translating it to SessionIssue.
      throw SessionIssue.invalidSavedSession;
    }
  }

  @override
  Future<void> save(StoredStopwatchSession session) => _enqueue(
    () => _preferences.setString(
      _sharedPreferencesKey,
      json.encode(session.toJson()),
    ),
  );

  Future<void> _enqueue(Future<void> Function() operation) {
    final Future<void> queuedOperation = _pendingWrite.then((_) => operation());
    _pendingWrite = queuedOperation.onError((Object _, StackTrace _) {});
    return queuedOperation;
  }

  Map<String, dynamic> _migrateIfNeeded(Map<String, dynamic> json) {
    final int schemaVersion = json['schemaVersion'] as int;

    if (schemaVersion == currentSchemaVersion) {
      return json;
    }

    // Future migrations would switch on the saved schema version.
    // For example, if currentSchemaVersion becomes 3:
    // return switch (schemaVersion) {
    //   1 => migrate2To3(migrate1To2(json)),
    //   2 => migrate2To3(json),
    //   _ => throw FormatException('Unsupported schema version: $schemaVersion'),
    // };
    // Each step transforms the fields, and updates schemaVersion
    // to the next version. Version 1 therefore passes through
    // both steps; version 3 is already handled by the check above.
    // Only the resulting current-version JSON is passed to fromJson().

    throw FormatException('Unsupported session schema version: $schemaVersion');
  }
}
