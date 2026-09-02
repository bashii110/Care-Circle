import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/care_models.dart';
import '../../../shared/widgets/care_scaffold.dart';
import '../../../shared/widgets/error_state_card.dart';
import '../application/medication_notifier.dart';
import '../domain/medication_schedule.dart';
import 'edit_medication_screen.dart';
import 'medication_dose_card.dart';
import 'medication_history_screen.dart';

/// Shows a medication's details, today's scheduled doses (with
/// TAKEN/SKIP actions — this is where srd.md's "record compliance"
/// actually happens), and entry points to edit, view history, or delete.
class MedicationDetailScreen extends ConsumerWidget {
  const MedicationDetailScreen({super.key, required this.medicationId});

  final String medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Medication>> medicationsState = ref.watch(medicationNotifierProvider);

    return CareScaffold(
      title: 'Medication',
      body: medicationsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => const ErrorStateCard(),
        data: (List<Medication> medications) {
          final Medication? medication = medications
              .cast<Medication?>()
              .firstWhere((Medication? m) => m?.id == medicationId, orElse: () => null);

          if (medication == null) {
            // It was just deleted (e.g. from another screen) — nothing more to show here.
            return const Center(child: Text('This medication was removed.'));
          }

          return _MedicationDetailView(medication: medication);
        },
      ),
    );
  }
}

class _MedicationDetailView extends ConsumerWidget {
  const _MedicationDetailView({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<MedicationDoseEvent> todaysDoses = MedicationSchedule.todaysDoses(medication);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(medication.name, style: textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(medication.dosage, style: textTheme.bodyLarge),
        if (medication.instructions?.isNotEmpty == true) ...<Widget>[
          const SizedBox(height: 8),
          Text(medication.instructions!, style: textTheme.bodyMedium),
        ],
        const SizedBox(height: 24),
        Text('Today', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        if (todaysDoses.isEmpty)
          Text('No reminder times configured.', style: textTheme.bodyMedium)
        else
          for (final MedicationDoseEvent event in todaysDoses) ...<Widget>[
            MedicationDoseCard(
              event: event,
              onMarkTaken: () => ref
                  .read(medicationNotifierProvider.notifier)
                  .markTaken(medication.id, event.scheduledAt),
              onMarkSkipped: () => ref
                  .read(medicationNotifierProvider.notifier)
                  .markSkipped(medication.id, event.scheduledAt),
            ),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MedicationHistoryScreen(medication: medication),
              ),
            );
          },
          icon: const Icon(Icons.history),
          label: const Text('View History'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => EditMedicationScreen(medication: medication),
              ),
            );
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Medication'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _confirmDelete(context, ref),
          style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete Medication'),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    // design.md §19 — destructive actions require confirmation that
    // states the concrete consequence, not just "are you sure?".
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete this medication?'),
        content: const Text(
          'This will permanently remove its dosage, reminder times, and '
          "compliance history. This can't be undone.",
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(medicationNotifierProvider.notifier).deleteMedication(medication.id);
    if (context.mounted) Navigator.of(context).pop();
  }
}
