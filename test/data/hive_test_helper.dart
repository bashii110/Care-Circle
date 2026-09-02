import 'dart:io';

import 'package:care_circle/core/constants/app_constants.dart';
import 'package:care_circle/data/models/care_models.dart';
import 'package:hive/hive.dart';

/// Initializes Hive against a fresh temp directory and registers all model
/// adapters (idempotently, since adapter registration is process-global).
///
/// Using a real temp-directory-backed Hive instance — rather than mocking
/// the box — is what lets these tests actually prove the Phase 1 exit
/// criteria in phases.md: "Records survive app restart" and "Empty
/// database works", not just that the repository calls the right methods.
Future<Directory> setUpTestHive() async {
  final Directory tempDir = await Directory.systemTemp.createTemp('care_circle_test_');
  Hive.init(tempDir.path);

  if (!Hive.isAdapterRegistered(HiveTypeIds.seniorProfile)) {
    Hive.registerAdapter(SeniorProfileAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveTypeIds.medication)) {
    Hive.registerAdapter(MedicationAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveTypeIds.healthVital)) {
    Hive.registerAdapter(HealthVitalAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveTypeIds.incidentLog)) {
    Hive.registerAdapter(IncidentLogAdapter());
  }

  return tempDir;
}

/// Closes all open boxes and removes the temp directory created by
/// [setUpTestHive].
Future<void> tearDownTestHive(Directory tempDir) async {
  await Hive.close();
  if (tempDir.existsSync()) {
    tempDir.deleteSync(recursive: true);
  }
}
