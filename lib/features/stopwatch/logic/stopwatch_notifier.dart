import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository_impl.dart';
import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_session.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';

part 'stopwatch_state.dart';

final NotifierProvider<StopwatchNotifier, StopwatchState>
stopwatchNotifierProvider = NotifierProvider<StopwatchNotifier, StopwatchState>(
  StopwatchNotifier.new,
);

class StopwatchNotifier extends Notifier<StopwatchState> {
  Timer? _timer;
  late final StopwatchService _stopwatchService;
  late final StopwatchSessionRepository _stopwatchSessionRepository;

  @override
  StopwatchState build() {
    _stopwatchService = ref.read(stopwatchServiceProvider);
    _stopwatchSessionRepository = ref.read(stopwatchSessionRepositoryProvider);
    ref.onDispose(() {
      _timer?.cancel();
      _stopwatchService.stop();
    });

    return .initial();
  }

  void start() {
    if (state.status == .running) {
      return;
    }
    _stopwatchService.start();
    _timer = Timer.periodic(Duration(milliseconds: 16), _updateElapsed);
    state = state.copyWith(status: .running);
    _stopwatchSessionRepository.save(state.toSession(savedAt: DateTime.now()));
  }

  void pause() {
    if (state.status != .running) {
      return;
    }
    _stopwatchService.stop();
    _timer?.cancel();
    state = state.copyWith(
      status: .paused,
      elapsed: _stopwatchService.elapsedTime,
    );
    _stopwatchSessionRepository.save(state.toSession(savedAt: DateTime.now()));
  }

  void reset() {
    _stopwatchService.reset();
    _timer?.cancel();
    state = .initial();
    _stopwatchSessionRepository.clear();
  }

  void recordLap() {
    if (state.status != .running) {
      return;
    }
    final Duration total = _stopwatchService.elapsedTime;
    final Lap lap = Lap(
      number: state.laps.length + 1,
      total: total,
      split:
          total -
          (state.laps.isNotEmpty ? state.laps.first.total : Duration.zero),
    );

    state = state.copyWith(elapsed: total, laps: [lap, ...state.laps]);
    _stopwatchSessionRepository.save(state.toSession(savedAt: DateTime.now()));
  }

  void clearLaps() {
    state = state.copyWith(elapsed: _stopwatchService.elapsedTime, laps: []);
    _stopwatchSessionRepository.save(state.toSession(savedAt: DateTime.now()));
  }

  void _updateElapsed(_) {
    state = state.copyWith(elapsed: _stopwatchService.elapsedTime);
  }
}
