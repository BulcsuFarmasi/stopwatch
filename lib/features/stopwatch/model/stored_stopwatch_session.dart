import 'package:stopwatch/features/stopwatch/model/lap.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_session.dart';
import 'package:stopwatch/features/stopwatch/model/stopwatch_status.dart';

const int currentSchemaVersion = 1;

class StoredStopwatchSession extends StopwatchSession {
  final DateTime savedAtUtc;

  final int schemaVersion;

  StoredStopwatchSession({
    this.schemaVersion = currentSchemaVersion,
    required super.elapsed,
    required this.savedAtUtc,
    required super.status,
    required super.laps,
  });

  Map<String, dynamic> toJson() => {
    "elapsedMicroseconds": elapsed.inMicroseconds,
    "savedAtMicroseconds": savedAtUtc.microsecondsSinceEpoch,
    "status": status.name,
    "laps": laps.map((Lap lap) => lap.toJson()).toList(),
    "schemaVersion": schemaVersion,
  };

  factory fromJson(Map<String, dynamic> json) {
    final Object? elapsedMicroseconds = json['elapsedMicroseconds'];
    final Object? savedAtMicroseconds = json['savedAtMicroseconds'];
    final Object? laps = json['laps'];
    final Object? statusEncoded = json['status'];
    final Object? schemaVersion = json['schemaVersion'];

    if (elapsedMicroseconds is! int || elapsedMicroseconds < 0) {
      throw const FormatException(
        "Elapsed time must be a non-negative integer",
      );
    }

    if (savedAtMicroseconds is! int || savedAtMicroseconds < 0) {
      throw const FormatException("Saved at must be a non-negative integer");
    }

    if (statusEncoded is! String) {
      throw const FormatException("Status must be stored as a string");
    }

    final StopwatchStatus status;
    try {
      status = StopwatchStatus.values.byName(statusEncoded);
    } on ArgumentError {
      throw const FormatException(
        "Status must be a recognized stopwatch status",
      );
    }

    if (laps is! List<dynamic>) {
      throw const FormatException("Laps should be a list");
    }

    if (laps.any((lap) => lap is! Map<String, dynamic>)) {
      throw const FormatException("Each lap must be a JSON object");
    }

    if (schemaVersion is! int || schemaVersion < 1) {
      throw const FormatException("Schema version must be a positive integer");
    }

    final DateTime savedAtUtc;
    try {
      savedAtUtc = DateTime.fromMicrosecondsSinceEpoch(
        savedAtMicroseconds,
        isUtc: true,
      );
    } on ArgumentError {
      throw const FormatException(
        "Saved timestamp is outside the supported range",
      );
    }

    final Duration elapsed = Duration(microseconds: elapsedMicroseconds);
    final List<Lap> parsedLaps = laps
        .cast<Map<String, dynamic>>()
        .map(Lap.fromJson)
        .toList();

    if (status == StopwatchStatus.initial &&
        (elapsed != Duration.zero || parsedLaps.isNotEmpty)) {
      throw const FormatException(
        "An initial session must have zero elapsed time and no laps",
      );
    }

    // Laps are stored newest first, with numbering restarted after clearing.
    for (int index = 0; index < parsedLaps.length; index++) {
      final Lap lap = parsedLaps[index];
      if (lap.number != parsedLaps.length - index) {
        throw const FormatException(
          "Lap numbers must be consecutive in newest-first order",
        );
      }
      if (lap.total > elapsed) {
        throw const FormatException(
          "Lap total must not exceed session elapsed time",
        );
      }

      final Duration previousTotal = index + 1 < parsedLaps.length
          ? parsedLaps[index + 1].total
          : Duration.zero;
      if (lap.total < previousTotal || lap.split != lap.total - previousTotal) {
        throw const FormatException(
          "Lap splits must match consecutive totals in newest-first order",
        );
      }
    }

    return StoredStopwatchSession(
      elapsed: elapsed,
      savedAtUtc: savedAtUtc,
      status: status,
      laps: parsedLaps,
      schemaVersion: schemaVersion,
    );
  }
}
