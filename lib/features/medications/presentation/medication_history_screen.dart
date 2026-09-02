import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/care_models.dart';
import '../../../shared/widgets/care_scaffold.dart';
import '../../../shared/widgets/empty_state_card.dart';

/// A single recorded compliance entry, parsed from
/// [Medication.complianceHistory] for display purposes.
class _HistoryEntry {
  const _HistoryEntry({required this.scheduledAt, required this.taken});

  final DateTime scheduledAt;
  final bool taken;
}

/// "Medication History" screen (phases.md Phase 3).
///
/// Shows every *recorded* compliance entry (taken or skipped) for a
/// medication, most recent first. Doses that haven't happened yet or
/// were never explicitly recorded don't appear here — see the "Today's
/// doses" section on the medication detail screen for those.
class MedicationHistoryScreen extends StatelessWidget {
  const MedicationHistoryScreen({super.key, required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final List<_HistoryEntry> entries = _parseHistory(medication)
      ..sort((_HistoryEntry a, _HistoryEntry b) => b.scheduledAt.compareTo(a.scheduledAt));

    return CareScaffold(
      title: '${medication.name} History',
      body: entries.isEmpty
          ? const EmptyStateCard(
              icon: Icons.history,
              title: 'No history yet',
              message: 'Doses you mark as taken or skipped will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) =>
                  _HistoryTile(entry: entries[index]),
            ),
    );
  }

  static List<_HistoryEntry> _parseHistory(Medication medication) {
    final List<_HistoryEntry> entries = <_HistoryEntry>[];
    medication.complianceHistory.forEach((String key, bool taken) {
      final DateTime? scheduledAt = DateTime.tryParse(key);
      if (scheduledAt != null) {
        entries.add(_HistoryEntry(scheduledAt: scheduledAt, taken: taken));
      }
    });
    return entries;
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final _HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final CareStatusColors statusColors = Theme.of(context).extension<CareStatusColors>()!;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final IconData icon = entry.taken ? Icons.check_circle : Icons.cancel;
    final String label = entry.taken ? 'TAKEN' : 'SKIPPED';
    final Color color = entry.taken ? statusColors.success : statusColors.warning;

    final DateTime at = entry.scheduledAt;
    final String dateText = '${at.year}-${at.month.toString().padLeft(2, '0')}-'
        '${at.day.toString().padLeft(2, '0')}';
    final String timeText = TimeOfDay.fromDateTime(at).format(context);

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text('$dateText at $timeText', style: textTheme.bodyLarge),
        trailing: Text(label, style: textTheme.labelLarge?.copyWith(color: color)),
      ),
    );
  }
}
