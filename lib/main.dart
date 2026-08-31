import 'package:care_circle/data/repositories/incident_repositories.dart';
import 'package:care_circle/data/repositories/medication_repositories.dart';
import 'package:care_circle/data/repositories/profile_repositories.dart';
import 'package:care_circle/data/repositories/vital_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/services/hive_storage_service.dart';
import 'core/services/preferences_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final HiveStorageService storage = HiveStorageService.instance;
  await storage.init();
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: <Override>[
        preferencesServiceProvider.overrideWithValue(
          PreferencesService(sharedPreferences),
        ),
        profileRepositoryProvider.overrideWithValue(
          HiveProfileRepository(storage.profileBox),
        ),
        medicationRepositoryProvider.overrideWithValue(
          HiveMedicationRepository(storage.medicationBox),
        ),
        vitalRepositoryProvider.overrideWithValue(
          HiveVitalRepository(storage.vitalsBox),
        ),
        incidentRepositoryProvider.overrideWithValue(
          HiveIncidentRepository(storage.incidentsBox),
        ),
      ],
      child: const CareCircleApp(),
    ),
  );
}