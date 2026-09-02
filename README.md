# CareCircle

An offline-first senior care tracking and caregiver handover application,
built with Flutter, Riverpod, and Hive. No backend is required for core
functionality.

Source-of-truth project documents live alongside this codebase:

- `srd.md` — requirements
- `architecture.md` — architecture blueprint
- `phases.md` — development phases / roadmap
- `design.md` — UI/UX specification

## Current status

**Phase 5 — Dashboard** (see `phases.md`) is complete on top of Phases
0–4. The Dashboard tab is now the real daily-care experience design.md §6
describes: a tappable senior header with an emergency call button, a
progress ring, today's medication timeline (derived live — never stored —
from the same status logic Phase 3 built), and quick actions. Vitals
(Phase 6) and Incidents (Phase 7) quick actions are visibly present but
intentionally disabled, since those features don't exist yet.

## Getting started

This repository was authored outside of a machine with the Flutter SDK
installed, so the platform scaffolding (`android/`, `ios/`, `web/`, etc.)
has **not** been generated yet, and `lib/data/models/care_models.g.dart`
is a hand-authored stand-in for what `hive_generator` would produce (see
the note at the top of that file). On a machine with Flutter installed:

```bash
flutter --version        # confirm Flutter is installed (3.24+ recommended)
flutter create .         # generates android/, ios/, and other platform folders
                          # in place, without touching lib/, test/, or pubspec.yaml
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerates care_models.g.dart
flutter analyze
flutter test
flutter run
```

If `flutter create .` prompts about overwriting `pubspec.yaml` or the
`lib/` directory, decline — this project already provides both.

## Project structure

```text
lib/
├── main.dart                     # Entry point: init Hive + SharedPreferences, run app
├── app/
│   ├── app.dart                  # Root MaterialApp + onboarding-gate/theme-mode/preferences providers
│   ├── router.dart               # Bottom-navigation shell (4 primary destinations)
│   └── theme/                    # Material 3 theme, typography, status colors, theme-mode codec
├── core/
│   ├── constants/                # Hive box names, type ids, SharedPreferences keys, sizing
│   ├── errors/                   # Failure types shared across repositories
│   ├── services/                 # HiveStorageService, PreferencesService, NotificationService
│   └── utils/                    # IdGenerator
├── data/
│   ├── models/                   # SeniorProfile, Medication, HealthVital, IncidentLog
│   │   ├── care_models.dart      # @HiveType classes + CareValidators-adjacent enums
│   │   ├── care_models.g.dart    # Hive TypeAdapters (hand-authored, see file header)
│   │   └── care_validators.dart  # Object- and field-level validation
│   └── repositories/             # Repository interfaces + Hive-backed implementations
├── features/
│   ├── onboarding/                # Phase 2 — 3-step flow (welcome, privacy/theme, create profile)
│   ├── profile/                   # Phase 2 — profile notifier, details screen, edit screen, shared form
│   ├── medications/                # Phase 3/4 — medication notifier, status calculator, list/detail/history screens
│   ├── dashboard/                 # Phase 5 — senior header, progress ring, today's timeline, quick actions
│   ├── vitals/                   # Phase 6
│   ├── incidents/                # Phase 7
│   ├── handover/                 # Phase 8
│   ├── settings/                  # later phases
│   └── security/                  # Phase 10
├── logic/                        # medication_scheduler.dart (Phase 4), care_timeline_engine.dart (Phase 5); reserved: report_engine.dart (Phase 8)
└── shared/
    ├── widgets/                  # CareScaffold, PhasePlaceholder, EmptyStateCard, ErrorStateCard, ProgressRing, EmergencyCallButton
    └── extensions/                # (reserved for later phases)
```

Folders reserved for later phases contain a `placeholder.dart` file with a
one-line comment rather than empty directories, since empty directories
aren't tracked by git.

## Architecture rules (see `architecture.md`)

- UI never touches Hive directly — always Widget → Notifier → Repository → Hive.
- Platform plugins (notifications, sharing, biometrics, phone dialer) are
  isolated behind services, never called from widgets.
- SharedPreferences holds only non-sensitive configuration.
- Hive type IDs, once released, are never reused or renumbered.

## Dependency policy

Only dependencies needed by the current phase are declared in
`pubspec.yaml`. Packages required by later phases (`share_plus`,
`local_auth`, `fl_chart`) are added when their phase begins, matching the
vertical-slice delivery strategy in `phases.md`. `hive_generator`/
`build_runner` were added in Phase 1. `flutter_local_notifications`,
`timezone`, and `flutter_timezone` were added in Phase 4. `url_launcher`
was added in Phase 5, for the Dashboard's emergency-call action.

## Phase 4 setup: native platform configuration

Local notifications need a few things `flutter create .` doesn't add on
its own — do these once you've generated the platform folders (see
Getting Started above):

- **Android** (`android/app/src/main/AndroidManifest.xml`): add
  `RECEIVE_BOOT_COMPLETED` (so a device reboot doesn't drop scheduled
  reminders) and `POST_NOTIFICATIONS` permissions. This project uses
  `AndroidScheduleMode.inexactAllowWhileIdle`, so `SCHEDULE_EXACT_ALARM`
  is **not** required — see the note in
  `flutter_local_notifications_service.dart` for why exact alarms were
  deliberately skipped for now.
- **iOS** (`ios/Runner/Info.plist`): no extra keys are required for local
  notifications specifically, but confirm background modes if you later
  want reminders to be more resilient to the app being force-quit.
- Follow `flutter_local_notifications`' own platform setup docs for
  anything version-specific — see the caveat below.

## A note on Phase 4's untested assumptions

`lib/core/services/flutter_local_notifications_service.dart` was written
without a working Flutter SDK or network access to verify it against the
real `flutter_local_notifications`/`timezone`/`flutter_timezone` package
APIs. The overall approach (initialize → create an Android channel →
request permission → `zonedSchedule` with
`matchDateTimeComponents: DateTimeComponents.time` for a daily-repeating
local-time reminder) is the standard pattern for this plugin trio, but
exact method/parameter names can drift between versions. Run
`flutter pub get` and `flutter analyze` locally; treat any errors there
as version-alignment fixes, not architectural problems, and let me know
what comes up.

## Phase 5 setup: iOS `tel:` scheme

The emergency-call button uses `url_launcher` with a `tel:` URI. On iOS,
add `tel` to `LSApplicationQueriesSchemes` in `ios/Runner/Info.plist` (a
few lines — see `url_launcher`'s own README) so `canLaunchUrl`/
`launchUrl` can detect and open the Phone app. Android needs no manifest
changes for `tel:`.

## Phase 5 design note: disabled Quick Actions

The Dashboard's "Log Vital" / "Incident" quick-action buttons are visible
(matching design.md §6's layout) but intentionally disabled with a
"Coming soon" tooltip — Vitals (Phase 6) and Incidents (Phase 7) don't
exist yet, and wiring the buttons to a screen that only pretends to log
something would violate the master prompt's "Important Rule" (§23) about
not faking unfinished functionality. They'll be enabled as their
respective phases land.
