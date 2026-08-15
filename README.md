# Stopwatch

A responsive stopwatch application built with Flutter and Dart. It supports
the complete basic stopwatch flow as well as recording, displaying, and
clearing lap times.

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

The content has a constrained maximum width for larger displays. Controls
reflow into a vertical layout on narrow screens, and vertical spacing is
reduced when the available height is limited. Lap entries scroll independently
while the lap header and Clear button remain visible.

The layout targets typical mobile, web, and desktop viewport sizes. Extremely
short viewports below approximately 350 logical pixels may overflow.

## Getting started

### Prerequisites

- Flutter installed and available on your `PATH`
- Dart SDK compatible with `^3.13.0`

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
