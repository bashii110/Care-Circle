import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/models/care_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateSeniorProfile', () {
    SeniorProfile buildValid() => SeniorProfile(
          id: '1',
          fullName: 'Ahmed',
          age: 72,
          emergencyContactPhone: '+92 300 1234567',
        );

    test('accepts a valid profile', () {
      expect(CareValidators.validateSeniorProfile(buildValid()), isNull);
    });

    test('rejects an empty name', () {
      final SeniorProfile profile = SeniorProfile(
        id: '1',
        fullName: '   ',
        age: 72,
        emergencyContactPhone: '+92 300 1234567',
      );
      expect(CareValidators.validateSeniorProfile(profile), isNotNull);
    });

    test('rejects an implausible age', () {
      final SeniorProfile profile = SeniorProfile(
        id: '1',
        fullName: 'Ahmed',
        age: 200,
        emergencyContactPhone: '+92 300 1234567',
      );
      expect(CareValidators.validateSeniorProfile(profile), isNotNull);
    });

    test('rejects a too-short phone number', () {
      final SeniorProfile profile = SeniorProfile(
        id: '1',
        fullName: 'Ahmed',
        age: 72,
        emergencyContactPhone: '123',
      );
      expect(CareValidators.validateSeniorProfile(profile), isNotNull);
    });
  });

  group('validateFullNameField', () {
    test('rejects empty/whitespace-only input', () {
      expect(CareValidators.validateFullNameField(''), isNotNull);
      expect(CareValidators.validateFullNameField('   '), isNotNull);
      expect(CareValidators.validateFullNameField(null), isNotNull);
    });

    test('accepts a real name', () {
      expect(CareValidators.validateFullNameField('Ahmed'), isNull);
    });
  });

  group('validateAgeField', () {
    test('rejects empty input', () {
      expect(CareValidators.validateAgeField(''), isNotNull);
    });

    test('rejects non-numeric input', () {
      expect(CareValidators.validateAgeField('seventy'), isNotNull);
    });

    test('rejects an implausible age', () {
      expect(CareValidators.validateAgeField('200'), isNotNull);
      expect(CareValidators.validateAgeField('-1'), isNotNull);
    });

    test('accepts a plausible age', () {
      expect(CareValidators.validateAgeField('72'), isNull);
    });
  });

  group('validatePhoneField', () {
    test('rejects empty input', () {
      expect(CareValidators.validatePhoneField(''), isNotNull);
    });

    test('rejects a too-short number', () {
      expect(CareValidators.validatePhoneField('123'), isNotNull);
    });

    test('accepts a plausible number', () {
      expect(CareValidators.validatePhoneField('+92 300 1234567'), isNull);
    });
  });

  group('validateMedication', () {
    test('accepts a valid medication', () {
      final Medication medication = Medication(
        id: '1',
        name: 'Metformin',
        dosage: '500 mg',
        alarmHours: <int>[8, 20],
        alarmMinutes: <int>[0, 0],
      );
      expect(CareValidators.validateMedication(medication), isNull);
    });

    test('rejects mismatched hour/minute list lengths', () {
      final Medication medication = Medication(
        id: '1',
        name: 'Metformin',
        dosage: '500 mg',
        alarmHours: <int>[8, 20],
        alarmMinutes: <int>[0],
      );
      expect(CareValidators.validateMedication(medication), isNotNull);
    });

    test('rejects an out-of-range hour', () {
      final Medication medication = Medication(
        id: '1',
        name: 'Metformin',
        dosage: '500 mg',
        alarmHours: <int>[25],
        alarmMinutes: <int>[0],
      );
      expect(CareValidators.validateMedication(medication), isNotNull);
    });

    test('rejects a medication with no reminder times', () {
      final Medication medication = Medication(
        id: '1',
        name: 'Metformin',
        dosage: '500 mg',
        alarmHours: <int>[],
        alarmMinutes: <int>[],
      );
      expect(CareValidators.validateMedication(medication), isNotNull);
    });
  });

  group('validateMedicationNameField', () {
    test('rejects empty input', () {
      expect(CareValidators.validateMedicationNameField(''), isNotNull);
      expect(CareValidators.validateMedicationNameField(null), isNotNull);
    });

    test('accepts a real name', () {
      expect(CareValidators.validateMedicationNameField('Metformin'), isNull);
    });
  });

  group('validateDosageField', () {
    test('rejects empty input', () {
      expect(CareValidators.validateDosageField(''), isNotNull);
    });

    test('accepts a real dosage', () {
      expect(CareValidators.validateDosageField('500 mg'), isNull);
    });
  });

  group('validateHealthVital', () {
    test('accepts a valid vital', () {
      final HealthVital vital = HealthVital(
        id: '1',
        timestamp: DateTime.now(),
        vitalType: VitalType.bloodPressure.storageValue,
        primaryValue: 120,
        secondaryValue: 80,
      );
      expect(CareValidators.validateHealthVital(vital), isNull);
    });

    test('rejects an unrecognized vital type', () {
      final HealthVital vital = HealthVital(
        id: '1',
        timestamp: DateTime.now(),
        vitalType: 'temperature',
        primaryValue: 98.6,
      );
      expect(CareValidators.validateHealthVital(vital), isNotNull);
    });

    test('rejects a non-positive measurement', () {
      final HealthVital vital = HealthVital(
        id: '1',
        timestamp: DateTime.now(),
        vitalType: VitalType.weight.storageValue,
        primaryValue: 0,
      );
      expect(CareValidators.validateHealthVital(vital), isNotNull);
    });

    test('rejects a future timestamp', () {
      final HealthVital vital = HealthVital(
        id: '1',
        timestamp: DateTime.now().add(const Duration(days: 1)),
        vitalType: VitalType.weight.storageValue,
        primaryValue: 70,
      );
      expect(CareValidators.validateHealthVital(vital), isNotNull);
    });
  });

  group('validateIncidentLog', () {
    test('accepts an incident with a tag but no description', () {
      final IncidentLog incident = IncidentLog(
        id: '1',
        timestamp: DateTime.now(),
        severity: IncidentSeverity.medium.storageValue,
        behaviorTags: 'Confusion',
      );
      expect(CareValidators.validateIncidentLog(incident), isNull);
    });

    test('accepts an incident with a description but no tags', () {
      final IncidentLog incident = IncidentLog(
        id: '1',
        timestamp: DateTime.now(),
        severity: IncidentSeverity.low.storageValue,
        detailedDescription: 'Seemed unsteady after lunch.',
      );
      expect(CareValidators.validateIncidentLog(incident), isNull);
    });

    test('rejects an incident with neither tags nor a description', () {
      final IncidentLog incident = IncidentLog(
        id: '1',
        timestamp: DateTime.now(),
        severity: IncidentSeverity.low.storageValue,
      );
      expect(CareValidators.validateIncidentLog(incident), isNotNull);
    });

    test('rejects an unrecognized severity', () {
      final IncidentLog incident = IncidentLog(
        id: '1',
        timestamp: DateTime.now(),
        severity: 'critical',
        behaviorTags: 'Confusion',
      );
      expect(CareValidators.validateIncidentLog(incident), isNotNull);
    });
  });
}
