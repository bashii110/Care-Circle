import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/care_models.dart';
import '../../../shared/widgets/care_scaffold.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../../shared/widgets/error_state_card.dart';
import '../application/medication_notifier.dart';
import 'add_medication_screen.dart';
import 'medication_detail_screen.dart';

/// "Medication List" screen (phases.md Phase 3).
class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Medication>> medicationsState = ref.watch(medicationNotifierProvider);

    return CareScaffold(
      title: 'Medications',
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add medication',
          onPressed: () => _handleAdd(context, medicationsState.valueOrNull ?? const <Medication>[]),
        ),
      ],
      body: medicationsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => const ErrorStateCard(),
        data: (List<Medication> medications) {
          if (medications.isEmpty) {
            return EmptyStateCard(
              icon: Icons.medication_outlined,
              title: 'No medications yet',
              message: 'Add a medication schedule to start\ntracking daily care.',
              actionLabel: 'Add Medication',
              onAction: () => _handleAdd(context, medications),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: medications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              return _MedicationListTile(medication: medications[index]);
            },
          );
        },
      ),
    );
  }

  void _handleAdd(BuildContext context, List<Medication> current) {
    if (current.length >= kFreeMedicationTierLimit) {
      showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Free plan limit reached'),
          content: const Text(
            'The free plan supports up to $kFreeMedicationTierLimit medications. '
            'Remove one to add another.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddMedicationScreen()),
    );
  }
}

class _MedicationListTile extends StatelessWidget {
  const _MedicationListTile({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String times = <String>[
      for (int i = 0; i < medication.alarmHours.length; i++)
        TimeOfDay(hour: medication.alarmHours[i], minute: medication.alarmMinutes[i])
            .format(context),
    ].join(', ');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(medication.name, style: textTheme.titleLarge),
        subtitle: Text(
          times.isEmpty ? medication.dosage : '${medication.dosage} • $times',
          style: textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MedicationDetailScreen(medicationId: medication.id),
            ),
          );
        },
      ),
    );
  }
}
