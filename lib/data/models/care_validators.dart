import 'care_models.dart';

/// Field-level validation for the domain models.
///
/// Each method returns `null` when the given object is valid, or a
/// caregiver-readable error message otherwise (srd.md §3's FR list of
/// required validations; master prompt §18). Repositories call these
/// before writing to Hive and throw a [ValidationFailure] with the
/// message on failure — see `hive_profile_repository.dart` and friends.
///
/// Kept as pure functions (no Hive/Flutter imports) so they're trivial to
/// unit test and to reuse later from form widgets for inline validation.
abstract final class CareValidators {
  static String? validateSeniorProfile(SeniorProfile profile) {
    final String? nameError = validateFullNameField(profile.fullName);
    if (nameError != null) return nameError;
    if (profile.age < 0 || profile.age > 130) {
      return 'Enter a valid age.';
    }
    final String? phoneError = validatePhoneField(profile.emergencyContactPhone);
    if (phoneError != null) return phoneError;
    return null;
  }

  /// Field-level check for a [SeniorProfile.fullName] form field, suitable
  /// for a [FormFieldValidator] (Phase 2 — onboarding/profile forms).
  static String? validateFullNameField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a full name.';
    }
    return null;
  }

  /// Field-level check for a [SeniorProfile.age] text field. Unlike
  /// [validateSeniorProfile], this works on the raw string a caregiver has
  /// typed so it can also catch non-numeric input.
  static String? validateAgeField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter an age.';
    }
    final int? age = int.tryParse(value.trim());
    if (age == null) {
      return 'Age must be a number.';
    }
    if (age < 0 || age > 130) {
      return 'Enter a valid age.';
    }
    return null;
  }

  /// Field-level check for [SeniorProfile.emergencyContactPhone].
  static String? validatePhoneField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter an emergency contact phone number.';
    }
    if (!_isPlausiblePhoneNumber(value)) {
      return 'Enter a valid emergency contact phone number.';
    }
    return null;
  }

  static String? validateMedication(Medication medication) {
    final String? nameError = validateMedicationNameField(medication.name);
    if (nameError != null) return nameError;
    final String? dosageError = validateDosageField(medication.dosage);
    if (dosageError != null) return dosageError;
    if (medication.alarmHours.isEmpty || medication.alarmMinutes.isEmpty) {
      return 'Add at least one reminder time.';
    }
    if (medication.alarmHours.length != medication.alarmMinutes.length) {
      return 'Each reminder needs both an hour and a minute.';
    }
    final bool hoursValid = medication.alarmHours.every((int h) => h >= 0 && h <= 23);
    final bool minutesValid =
        medication.alarmMinutes.every((int m) => m >= 0 && m <= 59);
    if (!hoursValid || !minutesValid) {
      return 'Reminder times must be valid times of day.';
    }
    return null;
  }

  /// Field-level check for [Medication.name].
  static String? validateMedicationNameField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a medication name.';
    }
    return null;
  }

  /// Field-level check for [Medication.dosage].
  static String? validateDosageField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a dosage.';
    }
    return null;
  }

  static String? validateHealthVital(HealthVital vital) {
    if (VitalType.fromStorageValue(vital.vitalType) == null) {
      return 'Unrecognized vital type.';
    }
    if (vital.primaryValue.isNaN || vital.primaryValue <= 0) {
      return 'Enter a valid measurement.';
    }
    if (vital.secondaryValue != null &&
        (vital.secondaryValue!.isNaN || vital.secondaryValue! <= 0)) {
      return 'Enter a valid second measurement.';
    }
    if (vital.timestamp.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return "Measurement time can't be in the future.";
    }
    return null;
  }

  static String? validateIncidentLog(IncidentLog incident) {
    if (IncidentSeverity.fromStorageValue(incident.severity) == null) {
      return 'Select a severity.';
    }
    if (incident.behaviorTagList.isEmpty && incident.detailedDescription.trim().isEmpty) {
      return 'Add a behavior tag or a short description.';
    }
    return null;
  }

  /// Loose validation: at least 7 digits, optionally with `+`, spaces,
  /// hyphens, or parentheses. Intentionally not strict about country
  /// formats, since caregivers may enter numbers from anywhere.
  static bool _isPlausiblePhoneNumber(String value) {
    final String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 7) return false;
    return RegExp(r'^[0-9+\-\s()]+$').hasMatch(value.trim());
  }
}
