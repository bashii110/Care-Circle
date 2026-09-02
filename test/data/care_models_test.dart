import 'package:care_circle/data/models/care_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeniorProfile', () {
    test('equality is value-based', () {
      final SeniorProfile a = SeniorProfile(
        id: '1',
        fullName: 'Ahmed',
        age: 72,
        emergencyContactPhone: '+92 300 1234567',
      );
      final SeniorProfile b = SeniorProfile(
        id: '1',
        fullName: 'Ahmed',
        age: 72,
        emergencyContactPhone: '+92 300 1234567',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith only changes the given fields', () {
      final SeniorProfile original = SeniorProfile(
        id: '1',
        fullName: 'Ahmed',
        age: 72,
        emergencyContactPhone: '+92 300 1234567',
      );
      final SeniorProfile updated = original.copyWith(age: 73);

      expect(updated.id, original.id);
      expect(updated.fullName, original.fullName);
      expect(updated.age, 73);
    });
  });

  group('Medication', () {
    test('defensively copies lists and maps', () {
      final List<int> hours = <int>[8, 20];
      final Medication medication = Medication(
        id: '1',
        name: 'Metformin',
        dosage: '500 mg',
        alarmHours: hours,
        alarmMinutes: <int>[0, 0],
      );

      hours.add(14); // mutate the original list after construction
      expect(medication.alarmHours, <int>[8, 20]);
      expect(() => medication.alarmHours.add(1), throwsUnsupportedError);
    });

    test('equality compares list/map contents, not identity', () {
      final Medication a = Medication(
        id: '1',
        name: 'Metformin',
        dosage: '500 mg',
        alarmHours: <int>[8, 20],
        alarmMinutes: <int>[0, 0],
        complianceHistory: const <String, bool>{'2026-08-30T08:00': true},
      );
      final Medication b = Medication(
        id: '1',
        name: 'Metformin',
        dosage: '500 mg',
        alarmHours: <int>[8, 20],
        alarmMinutes: <int>[0, 0],
        complianceHistory: const <String, bool>{'2026-08-30T08:00': true},
      );
      expect(a, equals(b));
    });
  });

  group('VitalType', () {
    test('round-trips through its storage value', () {
      for (final VitalType type in VitalType.values) {
        expect(VitalType.fromStorageValue(type.storageValue), type);
      }
    });

    test('unknown storage value returns null', () {
      expect(VitalType.fromStorageValue('not_a_real_type'), isNull);
    });
  });

  group('IncidentLog', () {
    test('behaviorTagList splits and trims comma-separated tags', () {
      final IncidentLog incident = IncidentLog(
        id: '1',
        timestamp: DateTime(2026, 8, 30, 18, 42),
        severity: IncidentSeverity.high.storageValue,
        behaviorTags: ' Confusion ,Fall / Slip,',
      );
      expect(incident.behaviorTagList, <String>['Confusion', 'Fall / Slip']);
    });

    test('behaviorTagList is empty when no tags are set', () {
      final IncidentLog incident = IncidentLog(
        id: '1',
        timestamp: DateTime(2026, 8, 30, 18, 42),
        severity: IncidentSeverity.low.storageValue,
      );
      expect(incident.behaviorTagList, isEmpty);
    });
  });
}
