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
stopwatchNotifierProvider = AsyncNotifierProvider<StopwatchNotifier, StopwatchState>(
  StopwatchNotifier.new,
);

class StopwatchNotifier extends AsyncNotifier<StopwatchState> {
  Timer? _timer;
  late final StopwatchService _stopwatchService;
  late final StopwatchSessionRepository _stopwatchSessionRepository;

  @override
  Future<StopwatchState> build() async {
    _stopwatchService = ref.read(stopwatchServiceProvider);
    _stopwatchSessionRepository = ref.read(stopwatchSessionRepositoryProvider);
    ref.onDispose(() {
      _timer?.cancel();
      _stopwatchService.stop();
    });

    return (await _restore()) ?? .initial();
  }



  void start() {
    final StopwatchState current = state.requireValue;
    if (current.status == .running) {
      return;
    }
    _stopwatchService.start();
    _startRefreshTimer();
    state = AsyncValue.data(current.copyWith(status: .running));
   _saveToSession();
  }

  void pause() {
    final StopwatchState current = state.requireValue;
    if (current.status != .running) {
      return;
    }
    _stopwatchService.stop();
    _timer?.cancel();
    state = AsyncValue.data( current.copyWith(
      status: .paused,
      elapsed: _stopwatchService.elapsedTime,
    ));
    _saveToSession();
  }

  void reset() {
    _stopwatchService.reset();
    _timer?.cancel();
    state = AsyncValue.data(.initial());
    _stopwatchSessionRepository.clear();
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

    state = AsyncValue.data(current.copyWith(elapsed: total, laps: [lap, ...current.laps]));
    _saveToSession();
  }

  void clearLaps() {
    final StopwatchState current = state.requireValue;
    state =  AsyncValue.data(current.copyWith(elapsed: _stopwatchService.elapsedTime, laps: []));
   _saveToSession();
  }

  void _updateElapsed(_) {
    final StopwatchState current = state.requireValue; 
    state = AsyncValue.data(current.copyWith(elapsed: _stopwatchService.elapsedTime));
  }

  void _saveToSession() {
    final StopwatchState current = state.requireValue;
    _stopwatchSessionRepository.save(current.toSession(savedAt: DateTime.now()));
  }

  void _startRefreshTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 16), _updateElapsed);
  }
  
    Future<StopwatchState?> _restore() async {
    final StopwatchSession? session = await _stopwatchSessionRepository.load();

    if (session == null || session.status == .initial) {
      return null;
    }

    final DateTime nowUtc = DateTime.now().toUtc();

    final Duration restoredElapsed = switch(session.status) {
      .running => session.elapsed + _nonNegativeDifference(nowUtc, session.savedAtUtc),
      .paused => session.elapsed,
      _ => Duration.zero
    };

    _stopwatchService.restoreElapsed(restoredElapsed);

    

    if (session.status == .running) {
      _stopwatchService.start();
      _startRefreshTimer();
    }

    return StopwatchState(elapsed: restoredElapsed, status: session.status, laps: session.laps);
  }


  Duration _nonNegativeDifference(DateTime later, DateTime earlier) {
    final Duration difference = later.difference(earlier);
    return difference.isNegative ? Duration.zero : difference;
  }
}
