// Centralizes the app's current English strings.
//
// A production implementation would use Flutter's generated ARB
// localizations with `intl` and `flutter_localizations`. For a larger team,
// a translation-management system (TMS) such as Crowdin, Lokalise, or Phrase Strings
// could manage and synchronize the ARB files.

abstract final class AppStrings {
  // APP
  static const String appTitle = "Stopwatch";

  // Controls
  static const String controlsStart = "Start";
  static const String controlsResume = "Resume";
  static const String controlsPause = "Pause";
  static const String controlsReset = "Reset";
  static const String controlsLap = "Lap";

  // Laps
  static const String lapsNumber = "Number";
  static const String lapsSplit = "Split";
  static const String lapsTotal = "Total";
  static const String clearLaps = "Clear laps";
  static const String lapsHeaderSemantics =
      "Laps. Columns: number, split, total";

  static String lapsSemantics({
    required int number,
    required String splitSemantics,
    required String totalSemantics,
  }) {
    return "Lap $number, $splitSemantics, $totalSemantics";
  }

  static String splitSemantics({
    required int minutes,
    required int seconds,
    required int milliseconds,
  }) {
    return "Split: ${durationSemantics(minutes: minutes, seconds: seconds, milliseconds: milliseconds)}";
  }

  static String totalSemantics({
    required int minutes,
    required int seconds,
    required int milliseconds,
  }) {
    return "Total: ${durationSemantics(minutes: minutes, seconds: seconds, milliseconds: milliseconds)}";
  }

  static const String elapsedTime = "Elapsed time:";
  static String durationSemantics({
    required int minutes,
    required int seconds,
    required int milliseconds,
  }) {
    final String minutesValue =
        "$minutes ${minutes == 1 ? "minute" : "minutes"}";
    final String secondsValue =
        "$seconds ${seconds == 1 ? "second" : "seconds"}";
    final String millisecondsvalue =
        "$milliseconds ${milliseconds == 1 ? "millisecond" : "milliseconds"}";

    return "$minutesValue, $secondsValue, $millisecondsvalue";
  }
}
