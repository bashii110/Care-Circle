import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/features/medications/domain/medication_schedule.dart';
import 'package:care_circle/logic/care_timeline_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns an empty timeline for an empty medication list', () {
    expect(CareTimelineEngine.buildTodayTimeline(<Medication>[]), isEmpty);
  });

  test('merges multiple medications into one chronologically sorted timeline', () {
    final DateTime now = DateTime(2026, 8, 30, 12, 0);

    final Medication metformin = Medication(
      id: 'med-1',
      name: 'Metformin',
      dosage: '500 mg',
      alarmHours: <int>[20, 8],
      alarmMinutes: <int>[0, 0],
    );
    final Medication lisinopril = Medication(
      id: 'med-2',
      name: 'Lisinopril',
      dosage: '10 mg',
      alarmHours: <int>[14],
      alarmMinutes: <int>[0],
    );

    final List<TimelineItem> timeline = CareTimelineEngine.buildTodayTimeline(
      <Medication>[metformin, lisinopril],
      now: now,
    );

    expect(timeline, hasLength(3));
    expect(timeline.map((TimelineItem i) => i.title), <String>[
      'Metformin', // 08:00
      'Lisinopril', // 14:00
      'Metformin', // 20:00
    ]);
    expect(
      timeline.map((TimelineItem i) => i.scheduledAt.hour),
      <int>[8, 14, 20],
    );
  });

  test('reflects each dose\'s real compliance status', () {
    final DateTime now = DateTime(2026, 8, 30, 12, 0);
    final DateTime morningDose = DateTime(2026, 8, 30, 8, 0);

    final Medication medication = Medication(
      id: 'med-1',
      name: 'Metformin',
      dosage: '500 mg',
      alarmHours: <int>[8, 20],
      alarmMinutes: <int>[0, 0],
      complianceHistory: <String, bool>{
        MedicationSchedule.complianceKeyFor(morningDose): true,
      },
    );

    final List<TimelineItem> timeline =
        CareTimelineEngine.buildTodayTimeline(<Medication>[medication], now: now);

    expect(timeline[0].status, MedicationEventStatus.completed); // 08:00, taken
    expect(timeline[1].status, MedicationEventStatus.pending); // 20:00, later today
  });
}
