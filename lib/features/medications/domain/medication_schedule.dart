import 'package:flutter/foundation.dart';

import '../../../data/models/care_models.dart';

/// The state of a single scheduled dose, per the master prompt's
/// "Important Medication Architecture" section:
///
/// ```
/// completed                                -> COMPLETED
/// now > scheduledTime + 60 minutes         -> OVERDUE
/// scheduledTime <= now                     -> PENDING
/// explicitly skipped                       -> SKIPPED
/// ```
enum MedicationEventStatus { completed, overdue, pending, skipped }

/// A single scheduled occurrence of a [Medication] on a specific day,
/// with its computed [status].
///
/// This is a *derived* view, not a persisted model — nothing about a
/// [MedicationDoseEvent] is stored directly; it's recomputed on demand
/// from [Medication.alarmHours]/[Medication.alarmMinutes] and
/// [Medication.complianceHistory] by [MedicationSchedule]. This mirrors
/// architecture.md §7's dashboard timeline principle ("The timeline
/// should be derived rather than permanently stored") applied at the
/// single-medication scope Phase 3 needs.
@immutable
class MedicationDoseEvent {
  const MedicationDoseEvent({
    required this.medication,
    required this.scheduledAt,
    required this.status,
  });

  final Medication medication;
  final DateTime scheduledAt;
  final MedicationEventStatus status;

  @override
  bool operator ==(Object other) {
    return other is MedicationDoseEvent &&
        other.medication.id == medication.id &&
        other.scheduledAt == scheduledAt &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(medication.id, scheduledAt, status);
}

/// Turns a [Medication]'s reminder times and compliance history into
/// concrete, status-aware [MedicationDoseEvent]s.
///
/// Phase 5's dashboard timeline (architecture.md §7,
/// `lib/logic/care_timeline_engine.dart`) rolls this same per-medication
/// logic up across every medication for "today" — it should reuse
/// [statusFor]/[scheduledTimesOn] rather than re-implementing the status
/// formula a second time.
abstract final class MedicationSchedule {
  /// The key a scheduled dose is recorded under in
  /// [Medication.complianceHistory]. Centralized here so every reader and
  /// writer of that map agrees on the exact format.
  static String complianceKeyFor(DateTime scheduledAt) => scheduledAt.toIso8601String();

  /// The times [medication] is scheduled on the given [date] (year/month/day
  /// taken from [date]; time-of-day from the medication's reminder times),
  /// sorted earliest to latest.
  static List<DateTime> scheduledTimesOn(Medication medication, DateTime date) {
    final List<DateTime> times = <DateTime>[
      for (int i = 0; i < medication.alarmHours.length; i++)
        DateTime(date.year, date.month, date.day, medication.alarmHours[i],
            medication.alarmMinutes[i]),
    ];
    times.sort();
    return times;
  }

  static MedicationEventStatus statusFor({
    required Medication medication,
    required DateTime scheduledAt,
    required DateTime now,
  }) {
    final bool? recorded = medication.complianceHistory[complianceKeyFor(scheduledAt)];
    if (recorded == true) return MedicationEventStatus.completed;
    if (recorded == false) return MedicationEventStatus.skipped;
    if (now.isAfter(scheduledAt.add(const Duration(minutes: 60)))) {
      return MedicationEventStatus.overdue;
    }
    return MedicationEventStatus.pending;
  }

  /// All of [medication]'s scheduled doses for "today" (relative to
  /// [now], which defaults to [DateTime.now]), each with its computed
  /// [MedicationDoseEvent.status].
  static List<MedicationDoseEvent> todaysDoses(Medication medication, {DateTime? now}) {
    final DateTime effectiveNow = now ?? DateTime.now();
    return <MedicationDoseEvent>[
      for (final DateTime scheduledAt in scheduledTimesOn(medication, effectiveNow))
        MedicationDoseEvent(
          medication: medication,
          scheduledAt: scheduledAt,
          status: statusFor(medication: medication, scheduledAt: scheduledAt, now: effectiveNow),
        ),
    ];
  }
}
