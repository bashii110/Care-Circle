import 'package:hive/hive.dart';

import '../models/care_models.dart';

/// Registers every Hive [TypeAdapter] used by CareCircle's local data
/// layer (architecture.md §4, §5).
///
/// Must be called once, before any box storing these types is opened
/// (architecture.md §13 — "Lifecycle and Reliability"). Idempotent, so
/// it's safe to call again — e.g. in tests that re-initialize Hive
/// against a fresh temp directory.
void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SeniorProfileAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(MedicationAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(HealthVitalAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(IncidentLogAdapter());
  }
}