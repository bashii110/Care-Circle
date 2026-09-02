import 'package:flutter/foundation.dart';

import '../data/models/care_models.dart';
import '../features/medications/domain/medication_schedule.dart';

/// One row in the dashboard's "Today" timeline (architecture.md §7 —
/// "Dashboard Timeline Engine").
///
/// Deliberately a plain value, not persisted — see [CareTimelineEngine].
@immutable
class TimelineItem {
  const TimelineItem({
    required this.medicationId,
    required this.title,
    required this.dosage,
    required this.scheduledAt,
    required this.status,
  });

  final String medicationId;
  final String title;
  final String dosage;
  final DateTime scheduledAt;
  final MedicationEventStatus status;

  @override
  bool operator ==(Object other) {
    return other is TimelineItem &&
        other.medicationId == medicationId &&
        other.scheduledAt == scheduledAt &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(medicationId, scheduledAt, status);
}

/// Rolls every medication's today's doses (Phase 3's
/// `MedicationSchedule`) up into a single, chronologically sorted
/// dashboard timeline (architecture.md §7).
///
/// ```
/// Inputs:
///   - Medication schedules.
///   - Medication completion history.
///   - Current time.
///   - Today's date.
/// Output:
///   TimelineItem { scheduledAt, medicationId, title, dosage, status }
/// ```
///
/// This intentionally reuses [MedicationSchedule.todaysDoses] rather than
/// re-implementing the completed/overdue/pending/skipped formula — see
/// that class's own doc comment, which named this exact reuse ahead of
/// time back in Phase 3.
abstract final class CareTimelineEngine {
  static List<TimelineItem> buildTodayTimeline(List<Medication> medications, {DateTime? now}) {
    final DateTime effectiveNow = now ?? DateTime.now();

    final List<TimelineItem> items = <TimelineItem>[
      for (final Medication medication in medications)
        for (final MedicationDoseEvent event
            in MedicationSchedule.todaysDoses(medication, now: effectiveNow))
          TimelineItem(
            medicationId: medication.id,
            title: medication.name,
            dosage: medication.dosage,
            scheduledAt: event.scheduledAt,
            status: event.status,
          ),
    ];

    items.sort((TimelineItem a, TimelineItem b) => a.scheduledAt.compareTo(b.scheduledAt));
    return items;
  }
}
