import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_session_handler.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_session.dart';
import 'package:stopwatch/features/stopwatch/model/stored_stopwatch_session.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';

part 'stopwatch_state.dart';

final AsyncNotifierProvider<StopwatchNotifier, StopwatchState>
stopwatchNotifierProvider =
    AsyncNotifierProvider<StopwatchNotifier, StopwatchState>(
      StopwatchNotifier.new,
    );

class StopwatchNotifier extends AsyncNotifier<StopwatchState> {
  Timer? _timer;
  bool _refreshEnabled = false;
  bool _sessionOperationInProgress = false;
  late final StopwatchService _stopwatchService;
  late final StopwatchSessionHandler _stopwatchSessionHandler;

  @override
  Future<StopwatchState> build() async {
    _stopwatchService = ref.read(stopwatchServiceProvider);
    _stopwatchSessionHandler = ref.read(stopwatchSessionHandlerProvider);
    ref.onDispose(() {
      stopRefreshTimer();
      _stopwatchService.stop();
    });

    final StopwatchState? restoredState = await _restore();

    return restoredState ?? .initial();
  }

  void start() {
    final StopwatchState current = state.requireValue;
    if (current.status == .running || _isSessionOperationBlocked(current)) {
      return;
    }
    state = AsyncValue.data(current.copyWith(status: .running));
    _stopwatchService.start();
    _scheduleRefreshTimer(status: .running);
    _saveToSession();
  }

  void startRefreshTimer() {
    _refreshEnabled = true;

    final StopwatchState? current = state.value;

    if (current == null || current.status != .running) {
      return;
    }

    _scheduleRefreshTimer(status: current.status);
    _updateElapsed();
  }

  void pause() {
    final StopwatchState current = state.requireValue;
    if (current.status != .running || _isSessionOperationBlocked(current)) {
      return;
    }
    _stopwatchService.stop();
    _timer?.cancel();
    state = AsyncValue.data(
      current.copyWith(status: .paused, elapsed: _stopwatchService.elapsedTime),
    );
    _saveToSession();
  }

  Future<void> reset() async {
    final StopwatchState current = state.requireValue;

    if (current.status == .initial || _isSessionOperationBlocked(current)) {
      return;
    }

    _stopwatchService.reset();
    _timer?.cancel();
    state = AsyncValue.data(.initial());
    await clearSavedSession();
  }

  void stopRefreshTimer() {
    _refreshEnabled = false;
    _timer?.cancel();
  }

  void recordLap() {
    final StopwatchState current = state.requireValue;
    if (current.status != .running || _isSessionOperationBlocked(current)) {
      return;
    }
    final Duration total = _stopwatchService.elapsedTime;
    final Lap lap = _getLapFromState(current, total);

    state = AsyncValue.data(
      current.copyWith(elapsed: total, laps: [lap, ...current.laps]),
    );
    _saveToSession();
  }

  void clearLaps() {
    final StopwatchState current = state.requireValue;

    if (_isSessionOperationBlocked(current)) {
      return;
    }

    state = AsyncValue.data(
      current.copyWith(elapsed: _stopwatchService.elapsedTime, laps: []),
    );
    _saveToSession();
  }

  Future<void> retrySessionRestore() async {
    await _runSessionOperation(() async {
      state = AsyncValue.data(await _restore() ?? .initial());
    });
  }

  Future<void> clearSavedSession() async {
    await _runSessionOperation(() async {
      try {
        await _stopwatchSessionHandler.clear();
        state = AsyncValue.data(.initial());
      } on SessionIssue catch (issue) {
        state = AsyncValue.data(.withIssue(issue));
      }
    });
  }

  void acknowledgeInvalidSavedSession() {
    final StopwatchState current = state.requireValue;

    if (current.sessionIssue != .invalidSavedSession) {
      return;
    }

    state = AsyncValue.data(current.copyWith(sessionIssue: null));
  }

  void _updateElapsed() {
    final StopwatchState current = state.requireValue;
    state = AsyncValue.data(
      current.copyWith(elapsed: _stopwatchService.elapsedTime),
    );
  }

  void _saveToSession() {
    final StopwatchState current = state.requireValue;
    _stopwatchSessionHandler.save(current.toSession(savedAt: DateTime.now()));
  }

  Future<StopwatchState?> _restore() async {
    try {
      final StopwatchSession? session = await _stopwatchSessionHandler
          .restore();

      if (session == null) {
        return null;
      }

      _stopwatchService.restoreElapsed(session.elapsed);

      if (session.status == .running) {
        _stopwatchService.start();
        _scheduleRefreshTimer(status: session.status);
      }

      return StopwatchState(
        elapsed: session.elapsed,
        status: session.status,
        laps: session.laps,
      );
    } on SessionIssue catch (issue) {
      return .withIssue(issue);
    }
  }

  void _scheduleRefreshTimer({StopwatchStatus? status}) {
    if (status != .running || (_timer?.isActive ?? false) || !_refreshEnabled) {
      return;
    }

    _timer = Timer.periodic(
      Duration(milliseconds: 16),
      (_) => _updateElapsed(),
    );
  }

  Future<void> _runSessionOperation(Future<void> Function() operation) async {
    if (_sessionOperationInProgress) {
      return;
    }

    _sessionOperationInProgress = true;

    try {
      await operation();
    } finally {
      _sessionOperationInProgress = false;
    }
  }

  bool _isSessionOperationBlocked(StopwatchState current) {
    return _sessionOperationInProgress ||
        current.sessionIssue == .readFailed ||
        current.sessionIssue == .clearFailed;
  }

  Lap _getLapFromState(StopwatchState state, Duration total) => Lap(
    number: state.laps.length + 1,
    total: total,
    split:
        total -
        (state.laps.isNotEmpty ? state.laps.first.total : Duration.zero),
  );
}
