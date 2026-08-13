import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<StopwatchService> stopwatchServiceProvider = Provider((_) => StopwatchService());

class StopwatchService {
  final Stopwatch _stopwatch = Stopwatch();

  Duration get elapsedTime => _stopwatch.elapsed;

  void start() {
    _stopwatch.start();
  }

  void stop() {
    _stopwatch.stop();
  }

  void reset() {
    _stopwatch.reset();
  }
}