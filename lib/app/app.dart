import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/services/preferences_service.dart';
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

/// Root widget. Owns [MaterialApp] configuration; all persistence and
/// business logic lives below the Riverpod provider layer, never here.
class CareCircleApp extends ConsumerWidget {
  const CareCircleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const CareCircleShell(),
    );
  }
}
