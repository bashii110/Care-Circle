import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/services/preferences_service.dart';
import '../features/onboarding/presentation/onboarding_flow.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Provides the app's [PreferencesService].
///
/// This has no default implementation — it is deliberately left
/// unimplemented ([UnimplementedError]) so that a missing override in
/// `main.dart` (or in a test) fails loudly instead of silently touching
/// disk. `main.dart` overrides this with a real instance built from an
/// awaited [SharedPreferences.getInstance()] before [runApp], and widget
/// tests override it with an instance built from
/// [SharedPreferences.setMockInitialValues].
final Provider<PreferencesService> preferencesServiceProvider =
    Provider<PreferencesService>((ref) {
  throw UnimplementedError(
    'preferencesServiceProvider must be overridden with a real '
    'PreferencesService before the app is run (see main.dart).',
  );
});

/// Whether onboarding (design.md §12) has been completed.
///
/// This mirrors [PreferencesService.onboardingCompleted] but as a reactive
/// [StateProvider], so completing onboarding mid-session immediately swaps
/// [CareCircleApp]'s `home` from [OnboardingFlow] to [CareCircleShell]
/// without needing an app restart. `main.dart` seeds its initial value
/// from [PreferencesService.onboardingCompleted]; `OnboardingFlow` flips
/// it (and persists the change) once the caregiver finishes step 3.
final StateProvider<bool> onboardingCompletedProvider = StateProvider<bool>((ref) {
  throw UnimplementedError(
    'onboardingCompletedProvider must be overridden before the app is run.',
  );
});

/// The app's current [ThemeMode], reactive for the same reason as
/// [onboardingCompletedProvider]: so a caregiver picking a theme during
/// onboarding sees it apply immediately, not after a restart.
final StateProvider<ThemeMode> themeModeProvider = StateProvider<ThemeMode>((ref) {
  throw UnimplementedError(
    'themeModeProvider must be overridden before the app is run.',
  );
});

/// Root widget. Owns [MaterialApp] configuration; all persistence and
/// business logic lives below the Riverpod provider layer, never here.
class CareCircleApp extends ConsumerWidget {
  const CareCircleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool onboardingCompleted = ref.watch(onboardingCompletedProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: onboardingCompleted ? const CareCircleShell() : const OnboardingFlow(),
    );
  }
}
