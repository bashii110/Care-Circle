/// Platform-agnostic interface for scheduling medication reminders
/// (architecture.md §11 — "Platform Integration": keep plugin code behind
/// a service interface, never called from widgets directly).
///
/// `FlutterLocalNotificationsService` is the real, plugin-backed
/// implementation. Tests use a fake implementing this interface instead
/// of touching platform channels, the same way `InMemoryProfileRepository`
/// stands in for `HiveProfileRepository`.
abstract interface class NotificationService {
  /// Initializes the underlying plugin, creates the Android notification
  /// channel, and requests notification permission. Safe to call more
  /// than once.
  Future<void> init();

  /// Schedules a daily-repeating reminder at [hour]:[minute] local time
  /// for one of a medication's scheduled doses.
  ///
  /// Calling this again with the same [medicationId]/[hour]/[minute]
  /// replaces the previously scheduled reminder rather than creating a
  /// duplicate — see [medicationNotificationId].
  Future<void> scheduleMedicationReminder({
    required String medicationId,
    required String medicationName,
    required String dosage,
    required int hour,
    required int minute,
  });

  /// Cancels the reminder previously scheduled for this exact
  /// medication + time, if any.
  Future<void> cancelMedicationReminder({
    required String medicationId,
    required int hour,
    required int minute,
  });
}

/// A deterministic notification id for a medication's dose at [hour]:[minute]
/// (master prompt §9 — "Notification identifiers must be deterministic";
/// architecture.md §8 — "Use deterministic notification IDs... This
/// prevents duplicate schedules").
///
/// This deliberately does **not** use Dart's built-in `String.hashCode`.
/// That hash is content-based but its exact algorithm is only guaranteed
/// stable within a single Dart SDK version — if a future Flutter/Dart
/// upgrade ever changed it, every previously scheduled OS-level
/// notification would become unreachable by any newly computed id, and
/// `cancelMedicationReminder` could never clean them up again. This uses
/// a fixed, self-contained FNV-1a hash instead, so the same
/// (medicationId, hour, minute) always maps to the same id regardless of
/// Dart version.
int medicationNotificationId({
  required String medicationId,
  required int hour,
  required int minute,
}) {
  final String key = '$medicationId|$hour|$minute';
  int hash = 0x811C9DC5; // FNV-1a 32-bit offset basis
  for (final int unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7FFFFFFF; // FNV prime; mask keeps it a positive 31-bit int
  }
  return hash;
}
