import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/logic/stopwatch_session_coordinator.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_session.dart';
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
  late final StopwatchService _stopwatchService;
  late final StopwatchSessionCoordinator _stopwatchSessionCoordinator;

  @override
  Future<StopwatchState> build() async {
    _stopwatchService = ref.read(stopwatchServiceProvider);
    _stopwatchSessionCoordinator = ref.read(
      stopwatchSessionCoordinatorProvider,
    );
    ref.onDispose(() {
      stopRefreshTimer();
      _stopwatchService.stop();
    });

    final StopwatchState? restoredState = await _restore();

    return restoredState ?? .initial();
  }

  void start() {
    final StopwatchState current = state.requireValue;
    if (current.status == .running || current.areStopwatchActionsBlocked) {
      return;
    }
    state = AsyncValue.data(current.copyWith(status: .running));
    _stopwatchService.start();
    _scheduleRefreshTimer(status: .running);
    unawaited(_saveToSession());
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
    if (current.status != .running || current.areStopwatchActionsBlocked) {
      return;
    }
    _stopwatchService.stop();
    _timer?.cancel();
    state = AsyncValue.data(
      current.copyWith(status: .paused, elapsed: _stopwatchService.elapsedTime),
    );
    unawaited(_saveToSession());
  }

  Future<void> reset() async {
    final StopwatchState current = state.requireValue;

    if (current.status == .initial || current.areStopwatchActionsBlocked) {
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
    if (current.status != .running || current.areStopwatchActionsBlocked) {
      return;
    }
    final Duration total = _stopwatchService.elapsedTime;
    final Lap lap = _getLapFromState(current, total);

    state = AsyncValue.data(
      current.copyWith(elapsed: total, laps: [lap, ...current.laps]),
    );
    unawaited(_saveToSession());
  }

  void clearLaps() {
    final StopwatchState current = state.requireValue;

    if (current.areStopwatchActionsBlocked) {
      return;
    }

    state = AsyncValue.data(
      current.copyWith(elapsed: _stopwatchService.elapsedTime, laps: []),
    );
    unawaited(_saveToSession());
  }

  Future<void> retrySessionRestore() async {
    await _runSessionOperation(() async {
      // Clear the current issue so a repeated failure emits a new state.
      final current = state.requireValue;
      state = AsyncValue.data(current.copyWith(sessionIssue: null));

      state = AsyncValue.data(await _restore() ?? .initial());
    });
  }

  Future<void> clearSavedSession() async {
    await _runSessionOperation(() async {
      // Clear the current issue so a repeated failure emits a new state.
      final current = state.requireValue;
      state = AsyncValue.data(current.copyWith(sessionIssue: null));
      try {
        await _stopwatchSessionCoordinator.clear();
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

  Future<void> _saveToSession() async {
    final StopwatchSession session = state.requireValue.toSession();

    try {
      await _stopwatchSessionCoordinator.save(session);

      final StopwatchState? current = state.value;
      if (current?.sessionIssue == .saveFailed) {
        state = AsyncValue.data(current!.copyWith(sessionIssue: null));
      }
    } on SessionIssue catch (issue) {
      final StopwatchState? current = state.value;
      if (current != null) {
        state = AsyncValue.data(current.copyWith(sessionIssue: issue));
      }
    }
  }

  Future<StopwatchState?> _restore() async {
    try {
      final StopwatchSession? session = await _stopwatchSessionCoordinator
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
        isSessionOperationInProgress: false,
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
    final StopwatchState current = state.requireValue;
    if (current.isSessionOperationInProgress) {
      return;
    }

    state = AsyncValue.data(
      current.copyWith(isSessionOperationInProgress: true),
    );

    try {
      await operation();
    } finally {
      final StopwatchState? current = state.value;

      if (current != null) {
        state = AsyncValue.data(
          current.copyWith(isSessionOperationInProgress: false),
        );
      }
    }
  }

  Lap _getLapFromState(StopwatchState state, Duration total) => Lap(
    number: state.laps.length + 1,
    total: total,
    split:
        total -
        (state.laps.isNotEmpty ? state.laps.first.total : Duration.zero),
  );
}
