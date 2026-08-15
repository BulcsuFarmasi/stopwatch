part of 'stopwatch_notifier.dart';

class StopwatchState {
  final Duration elapsed;
  final StopwatchStatus status;
  final List<Lap> laps;

  const new({required this.elapsed, required this.status, required this.laps});

  new initial() : elapsed = Duration.zero, status = .initial, laps = [];

  StopwatchState copyWith({
    Duration? elapsed,
    StopwatchStatus? status,
    List<Lap>? laps,
  }) {
    return StopwatchState(
      elapsed: elapsed ?? this.elapsed,
      status: status ?? this.status,
      laps: laps ?? this.laps,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StopwatchState &&
            elapsed == other.elapsed &&
            status == other.status &&
            laps == other.laps;
  }

  @override
  int get hashCode => Object.hash(elapsed, status, laps);
}

enum StopwatchStatus { initial, running, paused }

typedef Lap = ({Duration total, Duration split, int number});
