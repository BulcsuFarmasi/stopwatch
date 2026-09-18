import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';

class StopwatchSession {
  final Duration elapsed;
  final StopwatchStatus status;
  final List<Lap> laps;

  new({required this.elapsed, required this.status, required List<Lap> laps})
    : laps = List<Lap>.unmodifiable(laps);
}
