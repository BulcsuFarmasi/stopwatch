

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart';

part 'stopwatch_state.dart';

final NotifierProvider<StopwatchNotifier, StopwatchState> stopwatchNotifierProvider = NotifierProvider<StopwatchNotifier, StopwatchState>(StopwatchNotifier.new);

class StopwatchNotifier extends Notifier<StopwatchState> {

  Timer? _timer;
  late final StopwatchService _stopwatchService;

  @override
  StopwatchState build() {
    _stopwatchService = ref.read(stopwatchServiceProvider);
    ref.onDispose(() => _timer?.cancel());
    return StopwatchState.initial();
  }

  void start() {
    if (state.isRunning) {
      return;
    }
    _stopwatchService.start();
    _timer = Timer.periodic(Duration(milliseconds: 30), _updateElapsed);
    state = state.copyWith(isRunning: true);
  }

  void pause() {
    _stopwatchService.stop();
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _stopwatchService.stop();
    _stopwatchService.reset();
    _timer?.cancel();
    state = StopwatchState(elapsed: Duration.zero, isRunning: false);
  }

  void _updateElapsed(_) {
    state = state.copyWith(elapsed: _stopwatchService.elapsedTime);
  }
 }