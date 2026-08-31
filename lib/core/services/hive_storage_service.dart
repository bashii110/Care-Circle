import 'package:hive_flutter/hive_flutter.dart';

import '../../data/adapters/hive_adapters.dart';
import '../../data/models/care_models.dart';
import '../constants/app_constants.dart';
import '../errors/failures.dart';

/// Owns Hive initialization and box lifecycle.
///
/// Phase 1 introduces the four domain boxes (architecture.md §4); UI code
/// must never call [Hive.box] directly — always go through a repository
/// (architecture.md §3/§16).
class HiveStorageService {
  HiveStorageService._();

  static final HiveStorageService instance = HiveStorageService._();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Initializes Hive, registers adapters, and opens every box. Must be
  /// awaited before [runApp] (architecture.md §13).
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();
      registerHiveAdapters();

      await Hive.openBox<dynamic>(HiveBoxNames.appMetadata);
      await Hive.openBox<SeniorProfile>(HiveBoxNames.profile);
      await Hive.openBox<Medication>(HiveBoxNames.medication);
      await Hive.openBox<HealthVital>(HiveBoxNames.vitals);
      await Hive.openBox<IncidentLog>(HiveBoxNames.incidents);

      _initialized = true;
    } catch (_) {
      throw const StorageFailure();
    }
  }

  Box<dynamic> get appMetadataBox => _box<dynamic>(HiveBoxNames.appMetadata);
  Box<SeniorProfile> get profileBox => _box<SeniorProfile>(HiveBoxNames.profile);
  Box<Medication> get medicationBox => _box<Medication>(HiveBoxNames.medication);
  Box<HealthVital> get vitalsBox => _box<HealthVital>(HiveBoxNames.vitals);
  Box<IncidentLog> get incidentsBox => _box<IncidentLog>(HiveBoxNames.incidents);

  Box<T> _box<T>(String name) {
    if (!_initialized) {
      throw StateError(
        'HiveStorageService.init() must complete before accessing boxes.',
      );
    }
    return Hive.box<T>(name);
  }
}