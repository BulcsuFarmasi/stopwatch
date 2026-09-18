import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<StopwatchService> stopwatchServiceProvider = Provider(
  (_) => StopwatchService(),
);

class StopwatchService {
  Duration _baseElapsed = Duration.zero;
  final Stopwatch _stopwatch = Stopwatch();

  Duration get elapsedTime => _baseElapsed + _stopwatch.elapsed;

  void restoreElapsed(Duration elapsed) {
    _baseElapsed = elapsed;
    _stopwatch
      ..stop()
      ..reset();
  }

  void start() {
    _stopwatch.start();
  }

  void stop() {
    _stopwatch.stop();
  }

  void reset() {
    stop();
    _stopwatch.reset();
    _baseElapsed = Duration.zero;
  }
}
