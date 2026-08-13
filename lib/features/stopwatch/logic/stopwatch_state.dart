part of 'stopwatch_notifier.dart';

class StopwatchState {
  final Duration elapsed;
  final bool isRunning;

  const StopwatchState({required this.elapsed, required this.isRunning});

  StopwatchState.initial() : elapsed = Duration.zero, isRunning = false;

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
