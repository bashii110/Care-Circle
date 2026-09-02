import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/medication_schedule.dart';
import 'medication_status_style.dart';

/// A single scheduled-dose card (design.md §7 — "Medication Cards").
///
/// Status is always communicated with an icon, a text label, *and* a
/// color together (design.md Principle 3 — "Never rely on color alone"),
/// and [onMarkTaken]/[onMarkSkipped] are only offered while the dose is
/// still actionable (pending or overdue) — a completed or skipped dose is
/// already resolved and isn't re-editable from this card.
class MedicationDoseCard extends StatelessWidget {
  const MedicationDoseCard({
    super.key,
    required this.event,
    required this.onMarkTaken,
    required this.onMarkSkipped,
  });

  final MedicationDoseEvent event;
  final VoidCallback onMarkTaken;
  final VoidCallback onMarkSkipped;

  @override
  Widget build(BuildContext context) {
    final CareStatusColors statusColors = Theme.of(context).extension<CareStatusColors>()!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ({IconData icon, String label, Color color}) style =
        medicationStatusStyle(context, event.status);

    final String time = TimeOfDay.fromDateTime(event.scheduledAt).format(context);
    final bool isActionable = event.status == MedicationEventStatus.pending ||
        event.status == MedicationEventStatus.overdue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(style.icon, color: style.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${event.medication.dosage} • $time',
                    style: textTheme.bodyLarge,
                  ),
                ),
                Text(
                  style.label,
                  style: textTheme.labelLarge?.copyWith(color: style.color),
                ),
              ],
            ),
            if (event.status == MedicationEventStatus.overdue) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'OVERDUE BY ${DateTime.now().difference(event.scheduledAt).inMinutes} MIN',
                style: textTheme.bodyMedium?.copyWith(color: statusColors.error),
              ),
            ],
            if (isActionable) ...<Widget>[
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: onMarkTaken,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(kMinTouchTarget),
                      ),
                      child: const Text('TAKEN'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onMarkSkipped,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(kMinTouchTarget),
                      ),
                      child: const Text('SKIP'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
