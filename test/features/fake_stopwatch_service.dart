import 'package:stopwatch/features/stopwatch/service/stopwatch_service.dart'
    show StopwatchService;

class FakeStopwatchService extends StopwatchService {
  Duration _elapsed = Duration.zero;

  int startCalls = 0;
  int stopCalls = 0;
  int resetCalls = 0;

  bool isRunning = false;

  @override
  Duration get elapsedTime => _elapsed;

  @override
  void start() {
    startCalls++;
    isRunning = true;
  }

  @override
  void stop() {
    stopCalls++;
    isRunning = false;
  }

  @override
  void reset() {
    resetCalls++;
    stop();
    _elapsed = Duration.zero;
  }

  void advance(Duration duration) {
    if (isRunning) {
      _elapsed += duration;
    }
  }
}
