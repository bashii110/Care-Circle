import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/logic/medication_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_notification_service.dart';

void main() {
  Medication buildMedication({
    String id = 'med-1',
    List<int> hours = const <int>[8, 20],
    List<int> minutes = const <int>[0, 0],
  }) =>
      Medication(
        id: id,
        name: 'Metformin',
        dosage: '500 mg',
        alarmHours: hours,
        alarmMinutes: minutes,
      );

  test('scheduleAll schedules one reminder per reminder time', () async {
    final FakeNotificationService fake = FakeNotificationService();
    final MedicationScheduler scheduler = MedicationScheduler(fake);

    await scheduler.scheduleAll(buildMedication());

    expect(fake.scheduled, hasLength(2));
    expect(
      fake.scheduled.values.map((e) => (e.hour, e.minute)),
      containsAll(<(int, int)>[(8, 0), (20, 0)]),
    );
  });

  test('scheduleAll is idempotent — scheduling twice does not duplicate', () async {
    final FakeNotificationService fake = FakeNotificationService();
    final MedicationScheduler scheduler = MedicationScheduler(fake);

    final Medication medication = buildMedication();
    await scheduler.scheduleAll(medication);
    await scheduler.scheduleAll(medication);

    expect(fake.scheduled, hasLength(2));
  });

  test('cancelAll cancels every reminder time', () async {
    final FakeNotificationService fake = FakeNotificationService();
    final MedicationScheduler scheduler = MedicationScheduler(fake);

    final Medication medication = buildMedication();
    await scheduler.scheduleAll(medication);
    await scheduler.cancelAll(medication);

    expect(fake.scheduled, isEmpty);
    expect(fake.cancelled, hasLength(2));
  });

  test('reschedule cancels a removed time and keeps/adds the rest', () async {
    final FakeNotificationService fake = FakeNotificationService();
    final MedicationScheduler scheduler = MedicationScheduler(fake);

    final Medication previous = buildMedication(hours: <int>[8, 20], minutes: <int>[0, 0]);
    await scheduler.scheduleAll(previous);

    // Edited: drop 20:00, add 14:00 instead.
    final Medication updated = buildMedication(hours: <int>[8, 14], minutes: <int>[0, 0]);
    await scheduler.reschedule(previous: previous, updated: updated);

    final Set<(int, int)> remaining =
        fake.scheduled.values.map((e) => (e.hour, e.minute)).toSet();
    expect(remaining, <(int, int)>{(8, 0), (14, 0)});
  });
}
