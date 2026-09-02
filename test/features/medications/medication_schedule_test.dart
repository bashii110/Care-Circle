import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/features/medications/domain/medication_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Medication buildMedication({Map<String, bool> complianceHistory = const <String, bool>{}}) =>
      Medication(
        id: 'med-1',
        name: 'Metformin',
        dosage: '500 mg',
        alarmHours: <int>[20, 8],
        alarmMinutes: <int>[0, 0],
        complianceHistory: complianceHistory,
      );

  group('scheduledTimesOn', () {
    test('returns one DateTime per reminder time, sorted ascending', () {
      final DateTime date = DateTime(2026, 8, 30);
      final List<DateTime> times = MedicationSchedule.scheduledTimesOn(buildMedication(), date);

      expect(times, <DateTime>[
        DateTime(2026, 8, 30, 8, 0),
        DateTime(2026, 8, 30, 20, 0),
      ]);
    });
  });

  group('statusFor', () {
    final DateTime scheduledAt = DateTime(2026, 8, 30, 8, 0);

    test('is completed when explicitly recorded as taken', () {
      final Medication medication = buildMedication(
        complianceHistory: <String, bool>{
          MedicationSchedule.complianceKeyFor(scheduledAt): true,
        },
      );
      final MedicationEventStatus status = MedicationSchedule.statusFor(
        medication: medication,
        scheduledAt: scheduledAt,
        now: scheduledAt.add(const Duration(minutes: 5)),
      );
      expect(status, MedicationEventStatus.completed);
    });

    test('is skipped when explicitly recorded as skipped', () {
      final Medication medication = buildMedication(
        complianceHistory: <String, bool>{
          MedicationSchedule.complianceKeyFor(scheduledAt): false,
        },
      );
      final MedicationEventStatus status = MedicationSchedule.statusFor(
        medication: medication,
        scheduledAt: scheduledAt,
        now: scheduledAt.add(const Duration(minutes: 5)),
      );
      expect(status, MedicationEventStatus.skipped);
    });

    test('is pending before the scheduled time and within the 60-minute grace window', () {
      final Medication medication = buildMedication();

      expect(
        MedicationSchedule.statusFor(
          medication: medication,
          scheduledAt: scheduledAt,
          now: scheduledAt.subtract(const Duration(minutes: 10)),
        ),
        MedicationEventStatus.pending,
      );
      expect(
        MedicationSchedule.statusFor(
          medication: medication,
          scheduledAt: scheduledAt,
          now: scheduledAt.add(const Duration(minutes: 59)),
        ),
        MedicationEventStatus.pending,
      );
    });

    test('is overdue more than 60 minutes after the scheduled time with no record', () {
      final Medication medication = buildMedication();

      final MedicationEventStatus status = MedicationSchedule.statusFor(
        medication: medication,
        scheduledAt: scheduledAt,
        now: scheduledAt.add(const Duration(minutes: 61)),
      );
      expect(status, MedicationEventStatus.overdue);
    });
  });

  group('todaysDoses', () {
    test('produces one event per reminder time with the correct status', () {
      final DateTime now = DateTime(2026, 8, 30, 8, 30);
      final Medication medication = buildMedication(
        complianceHistory: <String, bool>{
          MedicationSchedule.complianceKeyFor(DateTime(2026, 8, 30, 8, 0)): true,
        },
      );

      final List<MedicationDoseEvent> doses = MedicationSchedule.todaysDoses(medication, now: now);

      expect(doses, hasLength(2));
      expect(doses[0].status, MedicationEventStatus.completed); // 8:00, taken
      expect(doses[1].status, MedicationEventStatus.pending); // 20:00, later today
    });
  });
}
