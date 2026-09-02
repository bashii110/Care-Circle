import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/medication_schedule.dart';

/// The icon/label/color for a [MedicationEventStatus], shared by every
/// place that renders a dose's status — `MedicationDoseCard` (Phase 3)
/// and the dashboard's `DashboardTimelineTile` (Phase 5) — so they always
/// agree, and design.md Principle 3 ("never rely on color alone") is
/// satisfied in exactly one place rather than re-implemented per widget.
({IconData icon, String label, Color color}) medicationStatusStyle(
  BuildContext context,
  MedicationEventStatus status,
) {
  final CareStatusColors statusColors = Theme.of(context).extension<CareStatusColors>()!;
  final ColorScheme colorScheme = Theme.of(context).colorScheme;

  return switch (status) {
    MedicationEventStatus.completed =>
      (icon: Icons.check_circle, label: 'TAKEN', color: statusColors.success),
    MedicationEventStatus.pending =>
      (icon: Icons.schedule, label: 'PENDING', color: colorScheme.primary),
    MedicationEventStatus.overdue =>
      (icon: Icons.error, label: 'OVERDUE', color: statusColors.error),
    MedicationEventStatus.skipped =>
      (icon: Icons.cancel, label: 'SKIPPED', color: statusColors.warning),
  };
}
