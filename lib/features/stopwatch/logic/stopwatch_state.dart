part of 'stopwatch_notifier.dart';

class StopwatchState {
  final Duration elapsed;
  final StopwatchStatus status;
  final List<Lap> laps;
  final SessionIssue? sessionIssue;
  final bool isSessionOperationInProgress;

  static const Object _notProvided = Object();

  const new({
    required this.elapsed,
    required this.status,
    required this.laps,
    required this.isSessionOperationInProgress,
    this.sessionIssue,
  });

  new initial()
    : elapsed = Duration.zero,
      status = .initial,
      laps = [],
      isSessionOperationInProgress = false,
      sessionIssue = null;

  new withIssue(this.sessionIssue)
    : elapsed = Duration.zero,
      status = .initial,
      isSessionOperationInProgress = false,
      laps = [];

  StopwatchState copyWith({
    Duration? elapsed,
    StopwatchStatus? status,
    List<Lap>? laps,
    Object? sessionIssue = _notProvided,
    bool? isSessionOperationInProgress,
  }) {
    return StopwatchState(
      elapsed: elapsed ?? this.elapsed,
      status: status ?? this.status,
      laps: laps ?? this.laps,
      isSessionOperationInProgress:
          isSessionOperationInProgress ?? this.isSessionOperationInProgress,
      sessionIssue: identical(sessionIssue, _notProvided)
          ? this.sessionIssue
          : sessionIssue as SessionIssue?,
    );
  }

  StopwatchSession toSession() =>
      StopwatchSession(
        elapsed: elapsed,
        status: status,
        laps: laps,
      );

  bool get areStopwatchActionsBlocked =>
      isSessionOperationInProgress ||
      sessionIssue == .readFailed ||
      sessionIssue == .clearFailed;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StopwatchState &&
            elapsed == other.elapsed &&
            status == other.status &&
            laps == other.laps &&
            sessionIssue == other.sessionIssue &&
            isSessionOperationInProgress == other.isSessionOperationInProgress;
  }

  @override
  int get hashCode => Object.hash(
    elapsed,
    status,
    laps,
    sessionIssue,
    isSessionOperationInProgress,
  );
}
