import 'package:stopwatch/features/stopwatch/model/stopwatch_session.dart';

abstract class StopwatchSessionRepository {
  Future<StopwatchSession?> load();
  Future<void> save(StopwatchSession session);
  Future<void> clear();
}
