part of 'stopwatch_notifier.dart';

class StopwatchState {
  final Duration elapsed;
  final StopwatchStatus status;

  const new({required this.elapsed, required this.status});

  new initial() : elapsed = Duration.zero, status = .initial;

  StopwatchState copyWith({Duration? elapsed, StopwatchStatus? status}) {
    return StopwatchState(
      elapsed: elapsed ?? this.elapsed,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StopwatchState &&
            elapsed == other.elapsed &&
            status == other.status;
  }

  @override
  int get hashCode => Object.hash(elapsed, status);
}

enum StopwatchStatus { initial, running, paused }
