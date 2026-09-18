import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository_impl.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_session.dart';
import 'package:stopwatch/features/stopwatch/model/stored_stopwatch_session.dart';

final Provider<StopwatchSessionCoordinator>
stopwatchSessionCoordinatorProvider = Provider<StopwatchSessionCoordinator>(
  (Ref ref) => StopwatchSessionCoordinator(
    stopwatchSessionRepository: ref.read(stopwatchSessionRepositoryProvider),
  ),
);

class StopwatchSessionCoordinator {
  final StopwatchSessionRepository _stopwatchSessionRepository;
  final DateTime Function() _currentTime;

  // Bounds restoration errors caused by large forward device-clock changes.
  // Duration uses fixed days, so this represents 180 days rather than calendar
  // months.
  static const Duration _maximumRestorationGap = Duration(days: 180);

  new({
    required this._stopwatchSessionRepository,
    DateTime Function()? currentTime,
  }) : _currentTime = currentTime ?? DateTime.now;

  Future<StopwatchSession?> restore() async {
    try {
      final StoredStopwatchSession? session = await _stopwatchSessionRepository
          .load();
      if (session == null || session.status == .initial) {
        return null;
      }

      final DateTime nowUtc = _currentTime().toUtc();

      final Duration restoredElapsed = switch (session.status) {
        .running =>
          session.elapsed + _clampDifference(nowUtc, session.savedAtUtc),
        .paused => session.elapsed,
        _ => Duration.zero,
      };

      return StopwatchSession(
        elapsed: restoredElapsed,
        status: session.status,
        laps: session.laps,
      );
    } on SessionIssue catch (issue) {
      if (issue == .invalidSavedSession) {
        await clear();
      }

      rethrow;
    }
  }

  Future<void> save(StopwatchSession session) async {
    final StoredStopwatchSession storedStopwatchSession =
        StoredStopwatchSession(
          elapsed: session.elapsed,
          savedAtUtc: _currentTime().toUtc(),
          status: session.status,
          laps: session.laps,
        );
    await _stopwatchSessionRepository.save(storedStopwatchSession);
  }

  Future<void> clear() async {
    await _stopwatchSessionRepository.clear();
  }

  Duration _clampDifference(DateTime later, DateTime earlier) {
    final Duration difference = later.difference(earlier);

    if (difference > _maximumRestorationGap) {
      return _maximumRestorationGap;
    }

    return difference.isNegative ? Duration.zero : difference;
  }
}
