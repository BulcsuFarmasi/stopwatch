import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';

part 'stopwatch_state.dart';

final NotifierProvider<StopwatchNotifier, StopwatchState>
stopwatchNotifierProvider = NotifierProvider<StopwatchNotifier, StopwatchState>(
  StopwatchNotifier.new,
);

class StopwatchNotifier extends Notifier<StopwatchState> {
  Timer? _timer;
  late final StopwatchService _stopwatchService;

  @override
  StopwatchState build() {
    _stopwatchService = ref.read(stopwatchServiceProvider);
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
  }

  void reset() {
    _stopwatchService.reset();
    _timer?.cancel();
    state = .initial();
  }

  void recordLap() {
    if (state.status != .running) {
      return;
    }
    final Duration total = _stopwatchService.elapsedTime;
    final Lap lap = (
      number: state.laps.length + 1,
      total: total,
      split:
          total -
          (state.laps.isNotEmpty ? state.laps.first.total : Duration.zero),
    );

    state = state.copyWith(elapsed: total, laps: [lap, ...state.laps]);
  }

  void clearLaps() {
    state = state.copyWith(laps: []);
  }

  void _updateElapsed(_) {
    state = state.copyWith(elapsed: _stopwatchService.elapsedTime);
  }
}
