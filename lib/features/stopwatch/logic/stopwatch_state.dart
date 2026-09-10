part of 'stopwatch_notifier.dart';

class StopwatchState {
  final Duration elapsed;
  final StopwatchStatus status;
  final List<Lap> laps;
  final SessionIssue? sessionIssue;

  static const Object _notProvided = Object();

  const new({
    required this.elapsed,
    required this.status,
    required this.laps,
    this.sessionIssue,
  });

  new initial()
    : elapsed = Duration.zero,
      status = .initial,
      laps = [],
      sessionIssue = null;

  new withIssue(this.sessionIssue)
    : elapsed = Duration.zero,
      status = .initial,
      laps = [];

  StopwatchState copyWith({
    Duration? elapsed,
    StopwatchStatus? status,
    List<Lap>? laps,
    Object? sessionIssue = _notProvided,
  }) {
    return StopwatchState(
      elapsed: elapsed ?? this.elapsed,
      status: status ?? this.status,
      laps: laps ?? this.laps,
      sessionIssue: identical(sessionIssue, _notProvided)
          ? this.sessionIssue
          : sessionIssue as SessionIssue?,
    );
  }

  StoredStopwatchSession toSession({required DateTime savedAt}) =>
      StoredStopwatchSession(
        elapsed: elapsed,
        savedAtUtc: savedAt.toUtc(),
        status: status,
        laps: laps,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StopwatchState &&
            elapsed == other.elapsed &&
            status == other.status &&
            laps == other.laps &&
            sessionIssue == other.sessionIssue;
  }

  @override
  int get hashCode => Object.hash(elapsed, status, laps, sessionIssue);
}
