import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository_impl.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
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
  late final StopwatchSessionRepository _stopwatchSessionRepository;

  @override
  Future<StopwatchState> build() async {
    _stopwatchService = ref.read(stopwatchServiceProvider);
    _stopwatchSessionRepository = ref.read(stopwatchSessionRepositoryProvider);
    ref.onDispose(() {
      stopRefreshTimer();
      _stopwatchService.stop();
    });

    final StopwatchState? restoredState = await _restore();

    return restoredState ?? .initial();
  }

  void start() {
    final StopwatchState current = state.requireValue;
    if (current.status == .running) {
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
    if (current.status != .running) {
      return;
    }
    _stopwatchService.stop();
    _timer?.cancel();
    state = AsyncValue.data(
      current.copyWith(status: .paused, elapsed: _stopwatchService.elapsedTime),
    );
    _saveToSession();
  }

  void reset() {
    _stopwatchService.reset();
    _timer?.cancel();
    state = AsyncValue.data(.initial());
    _stopwatchSessionRepository.clear();
  }

  void stopRefreshTimer() {
    _refreshEnabled = false;
    _timer?.cancel();
  }

  void recordLap() {
    final StopwatchState current = state.requireValue;
    if (current.status != .running) {
      return;
    }
    final Duration total = _stopwatchService.elapsedTime;
    final Lap lap = Lap(
      number: current.laps.length + 1,
      total: total,
      split:
          total -
          (current.laps.isNotEmpty ? current.laps.first.total : Duration.zero),
    );

    state = AsyncValue.data(
      current.copyWith(elapsed: total, laps: [lap, ...current.laps]),
    );
    _saveToSession();
  }

  void clearLaps() {
    final StopwatchState current = state.requireValue;
    state = AsyncValue.data(
      current.copyWith(elapsed: _stopwatchService.elapsedTime, laps: []),
    );
    _saveToSession();
  }

  void _updateElapsed() {
    final StopwatchState current = state.requireValue;
    state = AsyncValue.data(
      current.copyWith(elapsed: _stopwatchService.elapsedTime),
    );
  }

  void _saveToSession() {
    final StopwatchState current = state.requireValue;
    _stopwatchSessionRepository.save(
      current.toSession(savedAt: DateTime.now()),
    );
  }

  Future<StopwatchState?> _restore() async {
    final StopwatchSession? session = await _stopwatchSessionRepository.load();

    if (session == null || session.status == .initial) {
      return null;
    }

    final DateTime nowUtc = DateTime.now().toUtc();

    final Duration restoredElapsed = switch (session.status) {
      .running =>
        session.elapsed + _nonNegativeDifference(nowUtc, session.savedAtUtc),
      .paused => session.elapsed,
      _ => Duration.zero,
    };

    _stopwatchService.restoreElapsed(restoredElapsed);

    if (session.status == .running) {
      _stopwatchService.start();
      _scheduleRefreshTimer(status: session.status);
    }

    return StopwatchState(
      elapsed: restoredElapsed,
      status: session.status,
      laps: session.laps,
    );
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

  Duration _nonNegativeDifference(DateTime later, DateTime earlier) {
    final Duration difference = later.difference(earlier);
    return difference.isNegative ? Duration.zero : difference;
  }
}
