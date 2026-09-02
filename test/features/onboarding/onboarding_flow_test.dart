import 'package:care_circle/app/app.dart';
import 'package:care_circle/core/services/preferences_service.dart';
import 'package:care_circle/core/services/service_providers.dart';
import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/repositories/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dashboard/fake_emergency_call_service.dart';
import '../medications/in_memory_medication_repository.dart';
import '../profile/in_memory_profile_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'a new caregiver can complete onboarding and land on the Dashboard '
    'with their profile saved',
    (WidgetTester tester) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final InMemoryProfileRepository repository = InMemoryProfileRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            preferencesServiceProvider.overrideWithValue(PreferencesService(prefs)),
            onboardingCompletedProvider.overrideWith((ref) => false),
            themeModeProvider.overrideWith((ref) => ThemeMode.system),
            profileRepositoryProvider.overrideWithValue(repository),
            // The shell's Dashboard tab (Phase 5) is mounted as soon as
            // onboarding completes — see app_launch_test.dart's comment on
            // why this is needed even though this test never visits Vitals.
            medicationRepositoryProvider.overrideWithValue(InMemoryMedicationRepository()),
            emergencyCallServiceProvider.overrideWithValue(FakeEmergencyCallService()),
          ],
          child: const CareCircleApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1 — Welcome.
      expect(find.text('Get Started'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Step 2 — Privacy + theme.
      expect(find.text('Private by design'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 3 — Create profile.
      expect(find.text("Add the person you're caring for."), findsOneWidget);

      final Finder textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Ahmed'); // full name
      await tester.enterText(textFields.at(1), '72'); // age
      await tester.enterText(textFields.at(3), '+92 300 1234567'); // phone

      await tester.tap(find.text('Create Profile'));
      await tester.pumpAndSettle();

      // Onboarding is over — the four-tab shell is showing, with the new
      // profile's own header visible on the Dashboard (Phase 5).
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Ahmed'), findsOneWidget);
      expect(find.text('Age 72'), findsOneWidget);

      // ...and the profile was actually persisted.
      final List<SeniorProfile> saved = await repository.getAll();
      expect(saved, hasLength(1));
      expect(saved.single.fullName, 'Ahmed');
      expect(prefs.getBool('onboarding_completed'), isTrue);
    },
  );

  testWidgets(
    'a returning caregiver (onboarding already completed) sees the shell '
    'directly, with their existing profile reachable from Dashboard',
    (WidgetTester tester) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SeniorProfile existing = SeniorProfile(
        id: 'senior-1',
        fullName: 'Ahmed',
        age: 72,
        emergencyContactPhone: '+92 300 1234567',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            preferencesServiceProvider.overrideWithValue(PreferencesService(prefs)),
            onboardingCompletedProvider.overrideWith((ref) => true),
            themeModeProvider.overrideWith((ref) => ThemeMode.system),
            profileRepositoryProvider.overrideWithValue(
              InMemoryProfileRepository(seed: <SeniorProfile>[existing]),
            ),
            medicationRepositoryProvider.overrideWithValue(InMemoryMedicationRepository()),
            emergencyCallServiceProvider.overrideWithValue(FakeEmergencyCallService()),
          ],
          child: const CareCircleApp(),
        ),
      );
      await tester.pumpAndSettle();

      // No onboarding — straight to the shell, with the profile's header
      // already visible on the Dashboard (Phase 5) — no extra navigation
      // needed to see it, unlike the app-bar icon this replaced.
      expect(find.text('Get Started'), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Ahmed'), findsOneWidget);
      expect(find.text('Age 72'), findsOneWidget);

      // Tapping the header still reaches the full Profile Details screen.
      await tester.tap(find.text('Ahmed'));
      await tester.pumpAndSettle();

      expect(find.text('Senior Profile'), findsOneWidget); // the pushed screen's AppBar title
    },
  );
}
