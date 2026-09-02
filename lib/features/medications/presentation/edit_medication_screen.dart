import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/care_models.dart';
import '../../../shared/widgets/care_scaffold.dart';
import '../application/medication_notifier.dart';
import 'medication_form.dart';

/// "Edit Medication" screen (phases.md Phase 3).
class EditMedicationScreen extends ConsumerWidget {
  const EditMedicationScreen({super.key, required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CareScaffold(
      title: 'Edit Medication',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: MedicationForm(
            initialMedication: medication,
            submitLabel: 'Save Changes',
            onSubmit: (Medication updated) async {
              try {
                await ref.read(medicationNotifierProvider.notifier).updateMedication(updated);
                if (context.mounted) Navigator.of(context).pop();
                return null;
              } on Failure catch (failure) {
                return failure.message;
              }
            },
          ),
        ),
      ),
    );
  }
}
