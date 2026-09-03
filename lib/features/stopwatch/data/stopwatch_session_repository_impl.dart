import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_session.dart';

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
  Future<StopwatchSession?> load() async {
    final String? sessionEncoded = await _preferences.getString(
      _sharedPreferencesKey,
    );

    return sessionEncoded != null
        ? StopwatchSession.fromJson(json.decode(sessionEncoded))
        : null;
  }

  @override
  Future<void> save(StopwatchSession session) => _enqueue(
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
}
