import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';

class StopwatchSession {
  final Duration elapsed;
  final DateTime savedAtUtc;
  final StopwatchStatus status;
  final List<Lap> laps;

  final int schemaVersion;

  const StopwatchSession({
    this.schemaVersion = 1,
    required this.elapsed,
    required this.savedAtUtc,
    required this.status,
    required this.laps,
  });

  Map<String, dynamic> toJson() => {
    "elapsedMicroseconds": elapsed.inMicroseconds,
    "savedAtMicroseconds": savedAtUtc.microsecondsSinceEpoch,
    "status": status.name,
    "laps": laps.map((Lap lap) => lap.toJson()).toList(),
    "schemaVersion": schemaVersion,
  };

  factory fromJson(Map<String, dynamic> json) => StopwatchSession(
    elapsed: Duration(microseconds: json["elapsedMicroseconds"]),
    savedAtUtc: DateTime.fromMicrosecondsSinceEpoch(
      json["savedAtMicroseconds"],
      isUtc: true,
    ),
    status: StopwatchStatus.values.byName(json["status"]),
    laps: (json["laps"] as List<Map<String, dynamic>>)
        .map(Lap.fromJson)
        .toList(),
    schemaVersion: json["schemaVersion"],
  );
}
