import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/care_models.dart';
import '../constants/app_constants.dart';
import '../errors/failures.dart';

/// Owns Hive initialization, adapter registration, and box lifecycle.
///
/// UI code must never call [Hive.box] directly (architecture.md §3/§16).
/// It should go through a repository, which in turn is backed by boxes
/// obtained from this service.
class HiveStorageService {
  HiveStorageService._();

  static final HiveStorageService instance = HiveStorageService._();

  bool _initialized = false;

  /// Whether [init] has completed successfully.
  bool get isInitialized => _initialized;

  late Box<SeniorProfile> _profileBox;
  late Box<Medication> _medicationBox;
  late Box<HealthVital> _vitalsBox;
  late Box<IncidentLog> _incidentsBox;

  /// Initializes Hive, registers all model adapters, and opens every box.
  ///
  /// Must be awaited before [runApp] (see architecture.md §13 —
  /// "Lifecycle and Reliability").
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();

      // Registering the same typeId twice throws, which matters if a test
      // or a future hot-restart path calls init() more than once.
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

      await Hive.openBox<dynamic>(HiveBoxNames.appMetadata);
      _profileBox = await Hive.openBox<SeniorProfile>(HiveBoxNames.profiles);
      _medicationBox = await Hive.openBox<Medication>(HiveBoxNames.medications);
      _vitalsBox = await Hive.openBox<HealthVital>(HiveBoxNames.vitals);
      _incidentsBox = await Hive.openBox<IncidentLog>(HiveBoxNames.incidents);

      _initialized = true;
    } catch (_) {
      throw const StorageFailure();
    }
  }

  /// The app metadata box, for small non-domain bookkeeping values
  /// (e.g. a future schema-version marker for migrations).
  Box<dynamic> get appMetadataBox {
    _assertInitialized();
    return Hive.box<dynamic>(HiveBoxNames.appMetadata);
  }

  Box<SeniorProfile> get profileBox {
    _assertInitialized();
    return _profileBox;
  }

  Box<Medication> get medicationBox {
    _assertInitialized();
    return _medicationBox;
  }

  Box<HealthVital> get vitalsBox {
    _assertInitialized();
    return _vitalsBox;
  }

  Box<IncidentLog> get incidentsBox {
    _assertInitialized();
    return _incidentsBox;
  }

  void _assertInitialized() {
    if (!_initialized) {
      throw StateError(
        'HiveStorageService.init() must complete before accessing boxes.',
      );
    }
  }
}
