import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/id_generator.dart';
import '../../../data/models/care_models.dart';
import '../../../data/models/care_validators.dart';
import 'reminder_times_field.dart';

/// Shared create/edit form for a [Medication] (srd.md FR-04).
///
/// Mirrors `SeniorProfileForm`'s shape: [onSubmit] performs the actual
/// repository call and returns `null` on success or a caregiver-readable
/// error message on failure, so this single widget serves both the "Add
/// Medication" and "Edit Medication" screens.
class MedicationForm extends StatefulWidget {
  const MedicationForm({
    super.key,
    this.initialMedication,
    required this.submitLabel,
    required this.onSubmit,
  });

  /// When editing an existing medication, its current values. `null` when
  /// adding a new one.
  final Medication? initialMedication;

  final String submitLabel;

  /// Called with the assembled medication once client-side validation
  /// passes. Return `null` on success, or an error message to display.
  final Future<String?> Function(Medication medication) onSubmit;

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _instructionsController;
  List<TimeOfDay> _reminderTimes = <TimeOfDay>[];

  bool _isSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    final Medication? medication = widget.initialMedication;
    _nameController = TextEditingController(text: medication?.name ?? '');
    _dosageController = TextEditingController(text: medication?.dosage ?? '');
    _instructionsController = TextEditingController(text: medication?.instructions ?? '');
    _reminderTimes = medication == null
        ? <TimeOfDay>[]
        : <TimeOfDay>[
            for (int i = 0; i < medication.alarmHours.length; i++)
              TimeOfDay(hour: medication.alarmHours[i], minute: medication.alarmMinutes[i]),
          ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final Medication medication = Medication(
      id: widget.initialMedication?.id ?? IdGenerator.generate(),
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      instructions:
          _instructionsController.text.trim().isEmpty ? null : _instructionsController.text.trim(),
      alarmHours: <int>[for (final TimeOfDay t in _reminderTimes) t.hour],
      alarmMinutes: <int>[for (final TimeOfDay t in _reminderTimes) t.minute],
      // Preserve any existing compliance history when editing — this form
      // never resets or discards a caregiver's past taken/skipped records.
      complianceHistory: widget.initialMedication?.complianceHistory ?? const <String, bool>{},
    );

    final String? error = await widget.onSubmit(medication);

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _submitError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Medication name',
              helperText: 'Required',
            ),
            validator: CareValidators.validateMedicationNameField,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dosageController,
            decoration: const InputDecoration(
              labelText: 'Dosage',
              helperText: 'E.g. 500 mg',
            ),
            validator: CareValidators.validateDosageField,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _instructionsController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Instructions (optional)',
              helperText: 'E.g. Take with food',
            ),
          ),
          const SizedBox(height: 16),
          ReminderTimesField(
            initialTimes: _reminderTimes,
            onChanged: (List<TimeOfDay> times) => _reminderTimes = times,
          ),
          const SizedBox(height: 24),
          if (_submitError != null) ...<Widget>[
            Text(
              _submitError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(kMinTouchTarget)),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
