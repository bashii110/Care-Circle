/// Central location for app-wide constant values.
///
/// Keeping these here avoids magic strings scattered across the codebase
/// (see the "Code Quality" requirements in the master prompt) and gives
/// later phases a single, stable place to look when wiring up new
/// repositories, boxes, or preference flags.
library;

/// Human-facing app name, used in the [MaterialApp] title and onboarding.
const String kAppName = 'CareCircle';

/// Hive box names (architecture.md §4).
abstract final class HiveBoxNames {
  /// Small key/value box for app-level metadata that isn't a domain model
  /// (e.g. schema/migration bookkeeping). Distinct from SharedPreferences,
  /// which is reserved for simple UI preferences (architecture.md §4).
  static const String appMetadata = 'appMetadataBox';

  /// One box per domain model, introduced in Phase 1.
  static const String profiles = 'profileBox';
  static const String medications = 'medicationBox';
  static const String vitals = 'vitalsBox';
  static const String incidents = 'incidentsBox';
}

/// Hive `typeId`s for `@HiveType`-annotated models (architecture.md §5).
///
/// These must remain stable forever once released — never reuse a typeId
/// for a different model, and never renumber an existing `@HiveField`.
/// `4` is reserved for a future `MedicationEvent` model (see the "Recommended
/// schema improvement" note in srd.md §4) and is intentionally left unused
/// until that model is actually introduced.
abstract final class HiveTypeIds {
  static const int seniorProfile = 0;
  static const int medication = 1;
  static const int healthVital = 2;
  static const int incidentLog = 3;
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

/// Free-tier cap on active medications (srd.md §7 / phases.md Phase 3).
///
/// This is a plain constant, not an entitlement system — Phase 11
/// (Premium & RevenueCat) is what introduces real entitlement checks and a
/// paywall. Until then, this is simply the hard-coded free-plan number
/// `MedicationNotifier.addMedication` enforces.
const int kFreeMedicationTierLimit = 3;

/// Standard motion duration range used across the app (design.md §16).
const Duration kStandardTransitionDuration = Duration(milliseconds: 200);
