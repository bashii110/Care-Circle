import 'package:flutter/material.dart';

import '../../../../logic/care_timeline_engine.dart';
import '../../../medications/presentation/medication_detail_screen.dart';
import '../../../medications/presentation/medication_status_style.dart';

/// One compact row in the dashboard's "TODAY" timeline (design.md §6 —
/// e.g. "✓ 08:00  Metformin       TAKEN").
///
/// This is deliberately more compact than `MedicationDoseCard` (Phase 3) —
/// the dashboard is a "one glance" overview (design.md Principle 1), not
/// where a caregiver takes action. Tapping through to the medication's
/// detail screen is where TAKEN/SKIP actually happens.
class DashboardTimelineTile extends StatelessWidget {
  const DashboardTimelineTile({super.key, required this.item});

  final TimelineItem item;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ({IconData icon, String label, Color color}) style =
        medicationStatusStyle(context, item.status);
    final String time = TimeOfDay.fromDateTime(item.scheduledAt).format(context);

    return Card(
      child: ListTile(
        leading: Icon(style.icon, color: style.color),
        title: Text('$time   ${item.title}', style: textTheme.bodyLarge),
        trailing: Text(style.label, style: textTheme.labelLarge?.copyWith(color: style.color)),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MedicationDetailScreen(medicationId: item.medicationId),
            ),
          );
        },
      ),
    );
  }
}
