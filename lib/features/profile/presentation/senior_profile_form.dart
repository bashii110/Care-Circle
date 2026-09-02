import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/id_generator.dart';
import '../../../data/models/care_models.dart';
import '../../../data/models/care_validators.dart';

/// Common blood types offered in the optional dropdown. "Prefer not to
/// say" keeps the field genuinely optional per srd.md §4
/// (`bloodType` is not `Required`), rather than forcing a guess.
const List<String> _kBloodTypeOptions = <String>[
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
];

/// Shared create/edit form for a [SeniorProfile].
///
/// Used by both the onboarding flow's "Create Profile" step (design.md
/// §12 step 3) and the Profile Details screen's "Edit" action — the two
/// screens differ only in title/button label and in what happens
/// afterward, not in the form itself.
///
/// [onSubmit] performs the actual repository call and returns `null` on
/// success or a caregiver-readable error message on failure (typically a
/// `ValidationFailure`/`StorageFailure`'s `message`). Keeping that as a
/// return value — rather than having the form reach into a repository or
/// notifier itself — is what lets this same widget serve both screens
/// without knowing whether it's creating or updating.
class SeniorProfileForm extends StatefulWidget {
  const SeniorProfileForm({
    super.key,
    this.initialProfile,
    required this.submitLabel,
    required this.onSubmit,
  });

  /// When editing an existing profile, its current values. `null` when
  /// creating a new one.
  final SeniorProfile? initialProfile;

  /// Label for the primary action button (e.g. "Create Profile", "Save").
  final String submitLabel;

  /// Called with the assembled profile once client-side validation
  /// passes. Return `null` on success, or an error message to display.
  final Future<String?> Function(SeniorProfile profile) onSubmit;

  @override
  State<SeniorProfileForm> createState() => _SeniorProfileFormState();
}

class _SeniorProfileFormState extends State<SeniorProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _primaryConditionController;
  late final TextEditingController _phoneController;
  String? _bloodType;

  bool _isSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    final SeniorProfile? profile = widget.initialProfile;
    _fullNameController = TextEditingController(text: profile?.fullName ?? '');
    _ageController = TextEditingController(text: profile?.age.toString() ?? '');
    _primaryConditionController =
        TextEditingController(text: profile?.primaryCondition ?? '');
    _phoneController = TextEditingController(text: profile?.emergencyContactPhone ?? '');
    _bloodType = profile?.bloodType;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _primaryConditionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final SeniorProfile profile = SeniorProfile(
      id: widget.initialProfile?.id ?? IdGenerator.generate(),
      fullName: _fullNameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      primaryCondition: _primaryConditionController.text.trim().isEmpty
          ? null
          : _primaryConditionController.text.trim(),
      emergencyContactPhone: _phoneController.text.trim(),
      bloodType: _bloodType,
    );

    final String? error = await widget.onSubmit(profile);

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
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full name',
              helperText: 'Required',
            ),
            validator: CareValidators.validateFullNameField,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age',
              helperText: 'Required',
            ),
            validator: CareValidators.validateAgeField,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _primaryConditionController,
            decoration: const InputDecoration(
              labelText: 'Primary condition (optional)',
              helperText: 'E.g. Diabetes, early dementia',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Emergency contact phone',
              helperText: 'Required',
            ),
            validator: CareValidators.validatePhoneField,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            value: _bloodType,
            decoration: const InputDecoration(
              labelText: 'Blood type (optional)',
            ),
            items: <DropdownMenuItem<String?>>[
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Prefer not to say'),
              ),
              ..._kBloodTypeOptions.map(
                (String type) => DropdownMenuItem<String?>(
                  value: type,
                  child: Text(type),
                ),
              ),
            ],
            onChanged: (String? value) => setState(() => _bloodType = value),
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
