import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/care_models.dart';
import '../../../shared/widgets/care_scaffold.dart';
import '../application/medication_notifier.dart';
import 'medication_form.dart';

/// "Add Medication" screen (phases.md Phase 3).
class AddMedicationScreen extends ConsumerWidget {
  const AddMedicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CareScaffold(
      title: 'Add Medication',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: MedicationForm(
            submitLabel: 'Add Medication',
            onSubmit: (Medication medication) async {
              try {
                await ref.read(medicationNotifierProvider.notifier).addMedication(medication);
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
