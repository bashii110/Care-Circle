import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/notification_service.dart';
import '../core/services/service_providers.dart';
import '../data/models/care_models.dart';

/// Translates [Medication] reminder rules into [NotificationService] calls
/// (architecture.md §8 — "Medication Scheduling Architecture").
///
/// ```
/// Medication
///    ↓
/// MedicationScheduler
///    ↓
/// OS Notification API
/// ```
///
/// This is intentionally a thin layer: [NotificationService] already
/// exposes medication-shaped methods (`scheduleMedicationReminder`, not a
/// generic `schedule`), so there's no translation logic to speak of beyond
/// "one call per reminder time". What this class *does* own is the
/// three-step edit sequence architecture.md §8 specifies —
/// cancel-old / persist / schedule-new — expressed as [reschedule].
class MedicationScheduler {
  const MedicationScheduler(this._notificationService);

  final NotificationService _notificationService;

  /// Schedules a reminder for every one of [medication]'s reminder times.
  /// Safe to call repeatedly for the same medication — deterministic ids
  /// (see [medicationNotificationId]) mean a re-schedule replaces the
  /// existing reminder rather than duplicating it. This is what makes
  /// startup reconciliation safe to run unconditionally.
  Future<void> scheduleAll(Medication medication) async {
    for (int i = 0; i < medication.alarmHours.length; i++) {
      await _notificationService.scheduleMedicationReminder(
        medicationId: medication.id,
        medicationName: medication.name,
        dosage: medication.dosage,
        hour: medication.alarmHours[i],
        minute: medication.alarmMinutes[i],
      );
    }
  }

  /// Cancels the reminder for every one of [medication]'s reminder times
  /// — used when a medication is deleted.
  Future<void> cancelAll(Medication medication) async {
    for (int i = 0; i < medication.alarmHours.length; i++) {
      await _notificationService.cancelMedicationReminder(
        medicationId: medication.id,
        hour: medication.alarmHours[i],
        minute: medication.alarmMinutes[i],
      );
    }
  }

  /// Call this when an existing medication's reminder times may have
  /// changed. [previous] must be the medication's state *before* the
  /// edit, so its old times get cancelled even if they're no longer
  /// present in [updated] — otherwise a removed reminder time would keep
  /// firing forever.
  Future<void> reschedule({required Medication previous, required Medication updated}) async {
    await cancelAll(previous);
    await scheduleAll(updated);
  }
}

final Provider<MedicationScheduler> medicationSchedulerProvider =
    Provider<MedicationScheduler>((ref) {
  return MedicationScheduler(ref.watch(notificationServiceProvider));
});
