import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository.dart';
import 'package:stopwatch/features/stopwatch/data/stopwatch_session_repository_impl.dart';
import 'package:stopwatch/features/stopwatch/model/session_issue.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_session.dart';
import 'package:stopwatch/features/stopwatch/model/stored_stopwatch_session.dart';

final Provider<StopwatchSessionHandler> stopwatchSessionHandlerProvider =
    Provider<StopwatchSessionHandler>(
      (Ref ref) => StopwatchSessionHandler(
        stopwatchSessionRepository: ref.read(
          stopwatchSessionRepositoryProvider,
        ),
      ),
    );

class StopwatchSessionHandler {
  final StopwatchSessionRepository _stopwatchSessionRepository;
  final DateTime Function() _currentTime;

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
          session.elapsed + _nonNegativeDifference(nowUtc, session.savedAtUtc),
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

  Future<void> save(StoredStopwatchSession session) async {
    await _stopwatchSessionRepository.save(session);
  }

  Future<void> clear() async {
    try {
      await _stopwatchSessionRepository.clear();
    } catch (_) {
      throw SessionIssue.clearFailed;
    }
  }

  Duration _nonNegativeDifference(DateTime later, DateTime earlier) {
    final Duration difference = later.difference(earlier);
    return difference.isNegative ? Duration.zero : difference;
  }
}
