import 'package:care_circle/core/services/service_providers.dart';
import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/repositories/repository_providers.dart';
import 'package:care_circle/features/dashboard/presentation/dashboard_screen.dart';
import 'package:care_circle/features/medications/domain/medication_schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medications/in_memory_medication_repository.dart';
import '../profile/in_memory_profile_repository.dart';
import 'fake_emergency_call_service.dart';

Widget wrap({
  required InMemoryProfileRepository profileRepository,
  required InMemoryMedicationRepository medicationRepository,
  FakeEmergencyCallService? emergencyCallService,
}) {
  return ProviderScope(
    overrides: <Override>[
      profileRepositoryProvider.overrideWithValue(profileRepository),
      medicationRepositoryProvider.overrideWithValue(medicationRepository),
      emergencyCallServiceProvider.overrideWithValue(
        emergencyCallService ?? FakeEmergencyCallService(),
      ),
    ],
    child: const MaterialApp(home: DashboardScreen()),
  );
}

SeniorProfile buildProfile() => SeniorProfile(
      id: 'senior-1',
      fullName: 'Ahmed',
      age: 72,
      emergencyContactPhone: '+92 300 1234567',
    );

void main() {
  testWidgets('shows the profile header, an accurate progress ring, and '
      "today's timeline (Phase 5 exit criteria)", (WidgetTester tester) async {
    final DateTime now = DateTime.now();
    final DateTime scheduledAt = DateTime(now.year, now.month, now.day, 9, 0);
    final Medication medication = Medication(
      id: 'med-1',
      name: 'Metformin',
      dosage: '500 mg',
      alarmHours: <int>[9],
      alarmMinutes: <int>[0],
      // Recorded explicitly, so status is deterministically COMPLETED
      // regardless of what time this test actually runs.
      complianceHistory: <String, bool>{
        MedicationSchedule.complianceKeyFor(scheduledAt): true,
      },
    );

    await tester.pumpWidget(
      wrap(
        profileRepository: InMemoryProfileRepository(seed: <SeniorProfile>[buildProfile()]),
        medicationRepository: InMemoryMedicationRepository(seed: <Medication>[medication]),
      ),
    );
    await tester.pumpAndSettle();

    // Senior header (design.md §6).
    expect(find.text('Ahmed'), findsOneWidget);
    expect(find.text('Age 72'), findsOneWidget);
    expect(find.text('CALL'), findsOneWidget);

    // Progress ring never relies on color/shape alone — explicit text too.
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('MEDS DONE'), findsOneWidget);

    // Today's timeline shows the one dose, correctly as TAKEN.
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.textContaining('Metformin'), findsOneWidget);
    expect(find.text('TAKEN'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no medications', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        profileRepository: InMemoryProfileRepository(seed: <SeniorProfile>[buildProfile()]),
        medicationRepository: InMemoryMedicationRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No medications yet'), findsOneWidget);
    expect(find.text('0 / 0'), findsOneWidget);
  });

  testWidgets('quick action buttons are visible but disabled (Vitals/Incidents not built yet)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        profileRepository: InMemoryProfileRepository(seed: <SeniorProfile>[buildProfile()]),
        medicationRepository: InMemoryMedicationRepository(),
      ),
    );
    await tester.pumpAndSettle();

    final OutlinedButton logVitalButton =
        tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Log Vital'));
    final OutlinedButton incidentButton =
        tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Incident'));

    expect(logVitalButton.onPressed, isNull);
    expect(incidentButton.onPressed, isNull);
  });

  testWidgets('tapping CALL places a call to the emergency contact number', (
    WidgetTester tester,
  ) async {
    final FakeEmergencyCallService fakeCallService = FakeEmergencyCallService();

    await tester.pumpWidget(
      wrap(
        profileRepository: InMemoryProfileRepository(seed: <SeniorProfile>[buildProfile()]),
        medicationRepository: InMemoryMedicationRepository(),
        emergencyCallService: fakeCallService,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('CALL'));
    await tester.pumpAndSettle();

    expect(fakeCallService.callsPlaced, <String>['+92 300 1234567']);
  });
}
