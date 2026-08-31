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
}
