import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../errors/failures.dart';

/// Owns Hive initialization and box lifecycle.
///
/// No domain models (SeniorProfile, Medication, ...) exist yet — those,
/// along with their generated adapters, arrive in Phase 1. Phase 0 only
/// needs to prove that Hive initializes correctly and that a box can be
/// opened and survives app restarts, per the Phase 0 exit criteria in
/// phases.md ("Storage initialization works").
///
/// UI code must never call [Hive.box] directly (architecture.md §3/§16).
/// It should go through a repository, which in turn is backed by a
/// service like this one.
class HiveStorageService {
  HiveStorageService._();

  static final HiveStorageService instance = HiveStorageService._();

  bool _initialized = false;

  /// Whether [init] has completed successfully.
  bool get isInitialized => _initialized;

  /// Initializes Hive and opens the app metadata box.
  ///
  /// Must be awaited before [runApp] (see architecture.md §13 —
  /// "Lifecycle and Reliability").
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();
      await Hive.openBox<dynamic>(HiveBoxNames.appMetadata);
      _initialized = true;
    } catch (_) {
      throw const StorageFailure();
    }
  }

  /// The app metadata box, for small non-domain bookkeeping values
  /// (e.g. a future schema-version marker for migrations).
  Box<dynamic> get appMetadataBox {
    if (!_initialized) {
      throw StateError(
        'HiveStorageService.init() must complete before accessing boxes.',
      );
    }
    return Hive.box<dynamic>(HiveBoxNames.appMetadata);
  }
}
