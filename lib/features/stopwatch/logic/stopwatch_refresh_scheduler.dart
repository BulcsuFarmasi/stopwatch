import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<StopwatchRefreshScheduler> stopwatchRefreshSchedulerProvider =
    Provider<StopwatchRefreshScheduler>((_) => StopwatchRefreshScheduler());

class StopwatchRefreshScheduler {
  Timer? _timer;
  bool _refreshEnabled = false;

  static const _refreshDuration = Duration(milliseconds: 16);

  void startRefresh() {
    _refreshEnabled = true;
  }

  void stopRefresh() {
    _refreshEnabled = false;
  }

  void startTimer(VoidCallback callback) {
    if ((_timer?.isActive ?? false) || !_refreshEnabled) {
      return;
    }
    _timer = Timer.periodic(_refreshDuration, (_) => callback());
  }

  void stopTimer() {
    _timer?.cancel();
  }
}
