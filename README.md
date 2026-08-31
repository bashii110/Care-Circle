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

**Phase 0 — Project Foundation** (see `phases.md`). No domain features are
implemented yet; this phase establishes the app shell, theming, folder
structure, and storage initialization that every later phase builds on.

## Getting started

This repository was authored outside of a machine with the Flutter SDK
installed, so the platform scaffolding (`android/`, `ios/`, `web/`, etc.)
has **not** been generated yet. On a machine with Flutter installed:

```bash
flutter --version        # confirm Flutter is installed (3.24+ recommended)
flutter create .         # generates android/, ios/, and other platform folders
                          # in place, without touching lib/, test/, or pubspec.yaml
flutter pub get
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
│   ├── app.dart                  # Root MaterialApp + preferencesServiceProvider
│   ├── router.dart               # Bottom-navigation shell (4 primary destinations)
│   └── theme/                    # Material 3 theme, typography, status colors
├── core/
│   ├── constants/                # Hive box names, SharedPreferences keys, sizing
│   ├── errors/                   # Failure types shared across future repositories
│   ├── services/                 # HiveStorageService, PreferencesService
│   └── utils/                    # (reserved for later phases)
├── data/                         # (reserved for Phase 1 — models/repositories/storage)
├── features/
│   ├── dashboard/                # Phase 5
│   ├── vitals/                   # Phase 6
│   ├── incidents/                # Phase 7
│   ├── handover/                 # Phase 8
│   ├── onboarding/                # Phase 2
│   ├── medications/               # Phase 3
│   ├── profile/                   # Phase 2
│   ├── settings/                  # later phases
│   └── security/                  # Phase 10
├── logic/                        # (reserved for later phases — scheduler, report engine)
└── shared/
    ├── widgets/                  # CareScaffold, PhasePlaceholder
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
`pubspec.yaml`. Packages required by later phases
(`flutter_local_notifications`, `share_plus`, `local_auth`, `url_launcher`,
`fl_chart`, `hive_generator`/`build_runner`) are added when their phase
begins, matching the vertical-slice delivery strategy in `phases.md`.
