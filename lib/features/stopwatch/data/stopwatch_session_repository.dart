import 'package:stopwatch/features/stopwatch/model/stored_stopwatch_session.dart';

abstract class StopwatchSessionRepository {
  Future<StoredStopwatchSession?> load();
  Future<void> save(StoredStopwatchSession session);
  Future<void> clear();
}
