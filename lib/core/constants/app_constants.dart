/// Central location for app-wide constant values.
///
/// Keeping these here avoids magic strings scattered across the codebase
/// (see the "Code Quality" requirements in the master prompt) and gives
/// later phases a single, stable place to look when wiring up new
/// repositories, boxes, or preference flags.
library;

/// Human-facing app name, used in the [MaterialApp] title and onboarding.
const String kAppName = 'CareCircle';

/// Hive box names.
///
/// Only [appMetadataBoxName] is opened in Phase 0, since no domain models
/// exist yet. Phase 1 introduces `profileBox`, `medicationBox`,
/// `vitalsBox`, and `incidentsBox` (see architecture.md §4).
abstract final class HiveBoxNames {
  static const String appMetadata = 'appMetadataBox';

  /// Phase 1 (architecture.md §4). Type IDs for the models these boxes
  /// hold are fixed in care_models.dart and must never be renumbered.
  static const String profile = 'profileBox';
  static const String medication = 'medicationBox';
  static const String vitals = 'vitalsBox';
  static const String incidents = 'incidentsBox';
}

/// SharedPreferences keys.
///
/// Per architecture.md §4, SharedPreferences must only ever hold
/// non-sensitive configuration — never medical records or secrets.
abstract final class PreferenceKeys {
  static const String onboardingCompleted = 'onboarding_completed';
  static const String themeMode = 'theme_mode';
  static const String highContrastEnabled = 'high_contrast_enabled';
  static const String selectedProfileId = 'selected_profile_id';
}

/// Minimum recommended touch target size in logical pixels
/// (design.md — Principle 2: "Large and obvious").
const double kMinTouchTarget = 48.0;

/// Standard motion duration range used across the app (design.md §16).
const Duration kStandardTransitionDuration = Duration(milliseconds: 200);


