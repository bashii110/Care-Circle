import 'package:care_circle/app/app.dart';
import 'package:care_circle/core/services/preferences_service.dart';
import 'package:care_circle/core/services/service_providers.dart';
import 'package:care_circle/data/repositories/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/dashboard/fake_emergency_call_service.dart';
import 'features/medications/in_memory_medication_repository.dart';
import 'features/profile/in_memory_profile_repository.dart';

void main() {
  setUp(() {
    // Avoids touching real platform channels/disk in tests.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  // This suite exercises the main shell, so onboarding is pre-completed —
  // see test/features/onboarding/onboarding_flow_test.dart for the
  // first-launch (onboarding) path itself.
  Future<void> pumpApp(WidgetTester tester) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          preferencesServiceProvider.overrideWithValue(PreferencesService(prefs)),
          onboardingCompletedProvider.overrideWith((ref) => true),
          themeModeProvider.overrideWith((ref) => ThemeMode.system),
          profileRepositoryProvider.overrideWithValue(InMemoryProfileRepository()),
          // The Dashboard tab (Phase 5) now reads medications directly, so
          // every test that renders the shell needs this overridden too —
          // IndexedStack keeps all four tabs mounted at once (see
          // router.dart), not just whichever one is currently selected.
          medicationRepositoryProvider.overrideWithValue(InMemoryMedicationRepository()),
          emergencyCallServiceProvider.overrideWithValue(FakeEmergencyCallService()),
        ],
        child: const CareCircleApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('CareCircleApp launches on the Dashboard tab', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    // With no medications yet, the Dashboard's own empty state should show.
    expect(find.text('No medications yet'), findsOneWidget);

    // All four primary destinations must be reachable without a hamburger
    // menu (design.md §5).
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Dashboard'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Vitals'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Incidents'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Handover'), findsOneWidget);
  });

  testWidgets('Tapping a navigation destination switches tabs', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Vitals'));
    await tester.pumpAndSettle();

    expect(
      find.text('Blood pressure, glucose, weight, and heart rate tracking.'),
      findsOneWidget,
    );
  });
}
