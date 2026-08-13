part of 'stopwatch_notifier.dart';

class StopwatchState {
  final Duration elapsed;
  final bool isRunning;

  const new({required this.elapsed, required this.isRunning});

  new initial() : elapsed = Duration.zero, isRunning = false;

  bool get isPaused => elapsed > Duration.zero && !isRunning;

  bool get isInitial => elapsed == Duration.zero && !isRunning;

  StopwatchState copyWith({Duration? elapsed, bool? isRunning}) {
    return StopwatchState(
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StopwatchState &&
            elapsed == other.elapsed &&
            isRunning == other.isRunning;
  }

  @override
  int get hashCode => Object.hash(elapsed, isRunning);
}
