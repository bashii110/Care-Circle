import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/theme/theme_mode_codec.dart';
import 'core/services/flutter_local_notifications_service.dart';
import 'core/services/hive_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/preferences_service.dart';
import 'core/services/service_providers.dart';
import 'core/services/url_launcher_emergency_call_service.dart';
import 'data/models/care_models.dart';
import 'data/repositories/hive_incident_repository.dart';
import 'data/repositories/hive_medication_repository.dart';
import 'data/repositories/hive_profile_repository.dart';
import 'data/repositories/hive_vitals_repository.dart';
import 'data/repositories/repository_providers.dart';
import 'logic/medication_scheduler.dart';

Future<void> main() async {
  // Per architecture.md §13 ("Lifecycle and Reliability"), all storage
  // must be initialized before the widget tree is built.
  WidgetsFlutterBinding.ensureInitialized();

  final HiveStorageService storage = HiveStorageService.instance;
  await storage.init();
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final PreferencesService preferencesService = PreferencesService(sharedPreferences);

  // Platform services (architecture.md §13's "Initialize platform
  // services" step). A notification setup failure must never block
  // startup — see FlutterLocalNotificationsService's own doc comment —
  // so this is intentionally not awaited-and-rethrown into main().
  final NotificationService notificationService = FlutterLocalNotificationsService();
  try {
    await notificationService.init();
  } catch (_) {
    // Best-effort; the app remains fully usable without notifications.
  }
  final MedicationScheduler medicationScheduler = MedicationScheduler(notificationService);

  // Reconcile every existing medication's reminders once, unconditionally,
  // at startup (phases.md Phase 4 exit criteria — "do not duplicate after
  // restart"; architecture.md §13). This happens here, eagerly, rather
  // than only inside `MedicationNotifier.build()`, because that provider
  // is lazy: if a caregiver never opens the Medications screen in a given
  // session, its build() would never run, and existing reminders would
  // silently go unscheduled after every restart. Deterministic
  // notification ids (see `medicationNotificationId`) make repeating this
  // on every launch safe — it replaces, never duplicates.
  final List<Medication> existingMedications = storage.medicationBox.values.toList();
  for (final Medication medication in existingMedications) {
    try {
      await medicationScheduler.scheduleAll(medication);
    } catch (_) {
      // Best-effort — a single medication's notification problem must
      // not block startup or affect any other medication's reminders.
    }
  }

  runApp(
    ProviderScope(
      overrides: <Override>[
        preferencesServiceProvider.overrideWithValue(preferencesService),
        onboardingCompletedProvider.overrideWith(
          (ref) => preferencesService.onboardingCompleted,
        ),
        themeModeProvider.overrideWith(
          (ref) => themeModeFromStorageValue(preferencesService.themeMode),
        ),
        profileRepositoryProvider.overrideWithValue(
          HiveProfileRepository(storage.profileBox),
        ),
        medicationRepositoryProvider.overrideWithValue(
          HiveMedicationRepository(storage.medicationBox),
        ),
        vitalsRepositoryProvider.overrideWithValue(
          HiveVitalsRepository(storage.vitalsBox),
        ),
        incidentRepositoryProvider.overrideWithValue(
          HiveIncidentRepository(storage.incidentsBox),
        ),
        notificationServiceProvider.overrideWithValue(notificationService),
        medicationSchedulerProvider.overrideWithValue(medicationScheduler),
        emergencyCallServiceProvider.overrideWithValue(UrlLauncherEmergencyCallService()),
      ],
      child: const CareCircleApp(),
    ),
  );
}
