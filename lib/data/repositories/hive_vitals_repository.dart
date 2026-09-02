import 'package:hive/hive.dart';

import '../../core/errors/failures.dart';
import '../models/care_models.dart';
import '../models/care_validators.dart';
import 'vitals_repository.dart';

/// [VitalsRepository] backed by a Hive [Box].
class HiveVitalsRepository implements VitalsRepository {
  HiveVitalsRepository(this._box);

  final Box<HealthVital> _box;

  @override
  Future<List<HealthVital>> getAll() async {
    try {
      return _box.values.toList(growable: false);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<List<HealthVital>> getByTypeInRange(
    VitalType type, {
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final List<HealthVital> matches = _box.values
          .where(
            (HealthVital v) =>
                v.vitalType == type.storageValue &&
                !v.timestamp.isBefore(from) &&
                !v.timestamp.isAfter(to),
          )
          .toList()
        ..sort((HealthVital a, HealthVital b) => a.timestamp.compareTo(b.timestamp));
      return matches;
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<HealthVital?> getById(String id) async {
    try {
      return _box.get(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> add(HealthVital vital) async {
    final String? error = CareValidators.validateHealthVital(vital);
    if (error != null) throw ValidationFailure(error);

    try {
      await _box.put(vital.id, vital);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> update(HealthVital vital) async {
    final String? error = CareValidators.validateHealthVital(vital);
    if (error != null) throw ValidationFailure(error);

    if (!_box.containsKey(vital.id)) {
      throw const StorageFailure('That measurement no longer exists.');
    }

    try {
      await _box.put(vital.id, vital);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const StorageFailure('That measurement no longer exists.');
    }
    try {
      await _box.delete(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }
}
