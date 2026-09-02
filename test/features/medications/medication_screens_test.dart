import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/repositories/repository_providers.dart';
import 'package:care_circle/features/medications/presentation/add_medication_screen.dart';
import 'package:care_circle/features/medications/presentation/medication_detail_screen.dart';
import 'package:care_circle/features/medications/presentation/medication_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'in_memory_medication_repository.dart';

// NOTE: these tests deliberately avoid driving Flutter's native
// showTimePicker dialog (used by ReminderTimesField's "Add time" chip).
// Its internal widget structure varies across Flutter/Material versions,
// and this sandbox has no Flutter SDK to verify against — a test built
// against the wrong version's dial/button layout would be a false
// positive. The reminder-time *logic* is fully covered instead by
// medication_schedule_test.dart (pure domain logic) and
// medication_notifier_test.dart (markTaken/markSkipped), and these tests
// cover everything else: list/empty states, the free-tier limit dialog,
// and marking an already-scheduled dose taken.

Widget wrap(Widget child, {required InMemoryMedicationRepository repository}) {
  return ProviderScope(
    overrides: <Override>[
      medicationRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(home: child),
  );
}

Medication buildMedication({String id = 'med-1'}) => Medication(
      id: id,
      name: 'Metformin',
      dosage: '500 mg',
      alarmHours: <int>[8],
      alarmMinutes: <int>[0],
    );

void main() {
  testWidgets('shows the design.md empty state and navigates to Add Medication', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(const MedicationListScreen(), repository: InMemoryMedicationRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('No medications yet'), findsOneWidget);
    expect(find.text('Add a medication schedule to start\ntracking daily care.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Add Medication'));
    await tester.pumpAndSettle();

    expect(find.byType(AddMedicationScreen), findsOneWidget);
  });

  testWidgets('shows a limit dialog instead of Add Medication once 3 medications exist', (
    WidgetTester tester,
  ) async {
    final InMemoryMedicationRepository repository = InMemoryMedicationRepository(
      seed: <Medication>[
        buildMedication(id: 'med-1'),
        buildMedication(id: 'med-2'),
        buildMedication(id: 'med-3'),
      ],
    );

    await tester.pumpWidget(wrap(const MedicationListScreen(), repository: repository));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(3));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Free plan limit reached'), findsOneWidget);
    expect(find.byType(AddMedicationScreen), findsNothing);
  });

  testWidgets('marking a pending dose as taken updates its status to TAKEN', (
    WidgetTester tester,
  ) async {
    final InMemoryMedicationRepository repository = InMemoryMedicationRepository(
      seed: <Medication>[buildMedication()],
    );

    await tester.pumpWidget(
      wrap(const MedicationDetailScreen(medicationId: 'med-1'), repository: repository),
    );
    await tester.pumpAndSettle();

    // The 8:00 dose should show as PENDING or OVERDUE depending on the
    // clock the test runs at — either way, a TAKEN button is offered.
    expect(find.text('TAKEN'), findsOneWidget);
    await tester.tap(find.text('TAKEN'));
    await tester.pumpAndSettle();

    // After marking taken, the card's status label switches to TAKEN and
    // the action buttons disappear (no longer actionable).
    expect(find.text('TAKEN'), findsOneWidget); // now the status label only
    expect(find.widgetWithText(FilledButton, 'TAKEN'), findsNothing);
  });
}
