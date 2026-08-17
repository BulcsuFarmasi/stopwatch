# Stopwatch

A responsive stopwatch application built with Flutter and Dart. It combines
the complete basic stopwatch flow with lap recording and synchronized digital
and analog displays.

## Features

### Stopwatch

- Start the stopwatch from zero.
- Pause and resume without losing elapsed time.
- Reset the stopwatch to zero.
- Display elapsed time in `MM:SS.mmm` format.
- Prevent repeated Start presses from creating multiple timers.

### Laps

- Record laps while the stopwatch is running.
- Display each lap's number, split time, and total elapsed time.
- Show the newest lap first.
- Clear all recorded laps without interrupting the stopwatch.
- Clear elapsed time and laps when resetting the stopwatch.

### Analog clock

- Visualize elapsed time with hour, minute, and second hands.
- Keep the analog hands synchronized with the digital elapsed time.
- Scale the clock face, numerals, hands, center pin, and digital readout to the
  available space.

## Architecture

The application is organized by feature and separates timekeeping, state
management, and presentation:

```text
lib/
|-- app/
|   |-- app.dart
|   `-- theme/
`-- features/
    `-- stopwatch/
        |-- logic/
        |-- service/
        `-- view/
```

- `StopwatchService` wraps Dart's `Stopwatch` and acts as the source of truth
  for elapsed time.
- `StopwatchNotifier` owns the application state and coordinates stopwatch and
  lap operations.
- Riverpod provides state management and dependency injection.
- The UI is divided into focused widgets for the display, controls, and lap
  list.

The periodic timer only refreshes the UI from the underlying `Stopwatch`.
Elapsed time is therefore not calculated by counting timer callbacks, avoiding
accumulated timer drift.

## Responsive design

The content has a constrained maximum width for larger displays. Controls use
a compact two-column layout on narrow or short screens, while spacing and
padding are reduced when height is limited. The clock scales according to both
the available width and height. Lap entries scroll independently while the lap
header and Clear button remain visible.

The portrait layout is the primary mobile experience. Landscape remains
functional on typical device sizes, although unusually short viewports provide
less space for the clock and lap list.

## Getting started

### Prerequisites

- Flutter 3.47.0 installed and available on your `PATH`
- Dart 3.13.0 (included with Flutter 3.47.0)

### Install dependencies

```sh
flutter pub get
```

### Run the application

```sh
flutter run
```

Select a connected device or supported browser when prompted.

## Verification

Run the automated tests:

```sh
flutter test
```

Run static analysis:

```sh
flutter analyze
```

Check formatting:

```sh
dart format --output=none --set-exit-if-changed lib test
```

Create a web build:

```sh
flutter build web
```

## Tests

The test suite covers:

- Starting, pausing, resuming, and resetting the stopwatch.
- Elapsed-time updates and stopping behavior.
- Repeated Start calls.
- Lap recording, numbering, split times, and total times.
- Preventing lap recording while stopped or paused.
- Clearing and resetting recorded laps.
- Button enabled states and user interactions.
- Stopwatch and lap values rendered by the UI.

The stopwatch service is replaced with a controllable fake in notifier and
widget tests, keeping those tests deterministic.
