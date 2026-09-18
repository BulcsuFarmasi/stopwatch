# Stopwatch

A responsive Flutter stopwatch with lap recording, synchronized analog and
digital displays, durable session recovery, lifecycle-aware refresh behavior,
and accessibility support.

## Features

- Start, pause, resume, and reset the stopwatch.
- Display elapsed time in `MM:SS.mmm` format.
- Render synchronized analog hour, minute, and second hands.
- Record laps with their number, split time, and total elapsed time.
- Show the newest lap first and clear laps without stopping the stopwatch.
- Restore running or paused sessions, elapsed time, and laps after relaunch.
- Adapt the interface to portrait, landscape, compact, and larger layouts.

## Architecture

The code is organized by feature, with persistence, coordination, timing, state
management, and presentation kept separate:

```text
lib/
|-- app/
|   `-- theme/
|-- features/
|   `-- stopwatch/
|       |-- data/
|       |-- logic/
|       |-- model/
|       |-- service/
|       `-- view/
|-- l10n/
`-- shared/
```

| Component | Responsibility |
| --- | --- |
| `StopwatchService` | Wraps Dart's monotonic `Stopwatch` and measures elapsed time while the process is alive. |
| `StopwatchRefreshScheduler` | Owns the periodic UI refresh timer and stops it when refreshing is disabled. |
| `StopwatchNotifier` | Applies user actions and coordinates state, timing, refresh, and session operations. |
| `StopwatchSessionCoordinator` | Converts between runtime and stored sessions and reconstructs elapsed time during restoration. |
| `StopwatchSessionRepository` | Defines the persistence boundary. |
| `StopwatchSessionRepositoryImpl` | Serializes, validates, versions, queues, loads, saves, and clears SharedPreferences data. |
| `AppLifecycleObserver` | Converts platform lifecycle changes into visible/hidden callbacks without exposing lifecycle details to the notifier. |
| View widgets | Separate display, lap, control, and responsive-layout responsibilities. |

Riverpod provides state management and dependency injection. Widgets select
only the state they need, so elapsed-time ticks do not rebuild the controls or
lap list.

## Timekeeping and session continuity

The refresh timer never calculates elapsed time by counting callbacks. It only
reads the underlying `Stopwatch`, preventing accumulated timer drift when a
callback is delayed.

Session data is saved after meaningful user actions instead of on every
16-millisecond display refresh. A stored session contains:

- Elapsed time
- Save timestamp in UTC
- Stopwatch status
- Recorded laps
- Schema version

When the app is backgrounded, display refreshes stop to avoid unnecessary work.
When it becomes visible again, the display is refreshed immediately. If the
process was terminated while the stopwatch was running, restoration adds a
bounded, non-negative wall-clock difference since the last meaningful save.
Paused sessions restore their exact stored duration.

Storage operations are queued to prevent overlapping save and clear operations.
Saved JSON is validated before it reaches application state. The current schema
is version 1; the repository contains a documented boundary for adding explicit
step-by-step migrations when the schema changes.

### Recovery behavior

| Situation | Behavior |
| --- | --- |
| No saved session | Start with a clean stopwatch. |
| Valid session | Restore status, elapsed time, and laps. |
| Invalid or unsupported session | Discard it, start clean, and inform the user. |
| Storage read failure | Block stopwatch actions and offer Retry or Discard. |
| Storage save failure | Keep the in-memory stopwatch usable and warn that the latest state might not be restored. |
| Storage clear failure | Block stopwatch actions and show a retry-only dialog. |

The clear-failure behavior is an intentional, consistency-first choice for this
exercise: the dialog is not dismissible, and Retry calls the clear operation
again. If the platform storage failure persists, the user can remain stuck in
that dialog. A production version should provide a controlled escape such as
continuing with a clean in-memory session, while reporting the failed cleanup
for diagnosis. This limitation is documented rather than hidden behind a UI
that implies the persisted data was successfully removed.

Running-session recovery necessarily uses wall-clock time because Dart's
monotonic `Stopwatch` cannot survive process termination. A backward clock
change contributes no additional elapsed time. A forward recovery gap is capped
at 180 days to prevent an accidental or manual device-clock change from adding
years to a restored session. This is a bounded recovery policy, not clock-change
detection: the app cannot distinguish a genuine long-running session from an
incorrect wall clock after process termination.

## Responsive design

Portrait is the primary mobile layout. Landscape arranges the display, laps,
and controls horizontally, with the controls stacked to preserve space for the
clock and lap values; the control column becomes scrollable when enlarged text
cannot fit on a short landscape screen. Compact portrait layouts use two control
rows. On short portrait screens with enlarged text, the decorative analog clock
is omitted while the digital elapsed time remains visible, leaving enough space
for the fixed lap header and Clear laps button. Lap entries continue to scroll
lazily through `ListView.separated`.

## Accessibility and localization

- High-contrast primary and secondary control colors
- Visible keyboard-focus outlines
- Material tap-target sizing
- One grouped, non-live semantic description for the frequently updating
  analog/digital display
- Grouped lap-header and lap-row announcements
- Duplicate semantics excluded from custom-painted content
- Widget tests for semantics, labels, and accessibility guidelines

English strings are centralized in `AppStrings`. For a production application,
this would be replaced with Flutter's generated ARB localization using `intl`
and `flutter_localizations`. A translation-management platform such as Crowdin,
Lokalise, or Phrase could synchronize ARB files for a larger product and team.

## Third-party assets

Roboto Condensed Light and Medium were downloaded from Google Fonts. The
bundled font metadata identifies version 3.008 and licensing under the Apache
License 2.0. The full license text is included at
`assets/fonts/roboto_condensed/LICENSE.txt`.

## Performance

- Riverpod `select` limits elapsed-time rebuilds to the stopwatch display.
- Static clock-face painting is separated from frequently changing hands.
- A `RepaintBoundary` contains the display's frequent paint work.
- Refresh scheduling stops while the app is not visible.
- `SharedPreferences` writes occur only on meaningful state changes.

Flutter DevTools rebuild tracing and repaint visualization were used during
manual validation to inspect the update scope. Profile-mode testing on a
physical OnePlus 12R did not reveal persistent jank during normal stopwatch
use. These checks were manual, and no benchmark trace is committed.

## Security considerations

The current application is offline, has no accounts, network API, embedded
secrets, or sensitive user data. The saved stopwatch session therefore uses
SharedPreferences; it should not be treated as secure storage.

If future features introduce authentication, purchases, cloud synchronization,
or personalized themes, the security model should expand accordingly:

- Never embed service secrets in the client application.
- Use HTTPS for all network communication.
- Store authentication tokens in OS-backed secure storage, for example through
  `flutter_secure_storage`, rather than SharedPreferences.

These controls are intentionally documented rather than implemented without a
feature or threat model that requires them.

## Observability

This assignment does not transmit telemetry. In production, errors and stack
traces would be reported to Sentry or Firebase Crashlytics before being
translated into `SessionIssue` values.

## Getting started

The repository pins Flutter through FVM:

- Flutter 3.47.1
- Dart 3.13.1

Install dependencies and run the application:

```sh
fvm flutter pub get
fvm flutter run
```

Select a connected Android device or a supported browser when prompted.

## Verification

Check formatting, static analysis, and the unit/widget suite:

```sh
fvm dart format --output=none --set-exit-if-changed lib test integration_test
fvm flutter analyze
fvm flutter test --coverage
```

Run the production-wiring integration journey on a connected device:

```sh
fvm flutter test integration_test/stopwatch_flow_test.dart -d <device-id>
```

Create a web build:

```sh
fvm flutter build web
```

The latest recorded full unit/widget run completed 203 tests with 97.4% line
coverage. The integration journey covers clean launch, start, elapsed-time
progression, lap recording, pause, resume, and reset using production
dependencies and persistent storage.

Tests cover models and validation, the persistence repository, session
coordination, service timing, refresh scheduling, notifier behavior, lifecycle
mapping, responsive layouts, individual widgets, accessibility semantics, and
the assembled screen. Time and dependencies are controlled where determinism
is required; the integration test intentionally uses real elapsed time.

## Launcher icon and splash generation

Source assets and package configuration are committed so platform resources can
be regenerated consistently:

```sh
fvm dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
fvm dart run flutter_native_splash:create -p flutter_native_splash.yaml
```

The launcher configuration generates Android legacy, adaptive, monochrome,
iOS, and web icons. The splash configuration includes a separately padded image
for the Android 12 system mask.

## Platform validation

- Android: manually verified on a physical OnePlus 12R, including portrait,
  landscape, lifecycle/session restoration, TalkBack, launcher icon, splash,
  and the primary stopwatch journey.
- Web: manually verified in Chrome, including responsive layout, keyboard
  navigation, launcher assets, and splash behavior.
- iOS: resources and identifiers are configured, but runtime behavior has not
  been verified because an iOS device was not available.
