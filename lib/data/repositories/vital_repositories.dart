import 'package:hive/hive.dart';

import '../../core/errors/failures.dart';
import '../models/care_models.dart';

abstract class VitalRepository {
  List<HealthVital> getAll();
  HealthVital? getById(String id);
  Future<void> add(HealthVital vital);
  Future<void> update(HealthVital vital);
  Future<void> delete(String id);
}

class HiveVitalRepository implements VitalRepository {
  HiveVitalRepository(this._box);

  final Box<HealthVital> _box;

  @override
  List<HealthVital> getAll() => _box.values.toList(growable: false);

  @override
  HealthVital? getById(String id) => _box.get(id);

  @override
  Future<void> add(HealthVital vital) async {
    _validate(vital);
    await _put(vital);
  }

  @override
  Future<void> update(HealthVital vital) async {
    _validate(vital);
    if (!_box.containsKey(vital.id)) {
      throw const ValidationFailure('That measurement no longer exists.');
    }
    await _put(vital);
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  Future<void> _put(HealthVital vital) async {
    try {
      await _box.put(vital.id, vital);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  void _validate(HealthVital vital) {
    if (!VitalTypes.all.contains(vital.vitalType)) {
      throw const ValidationFailure('Unknown measurement type.');
    }
    if (!vital.primaryValue.isFinite || vital.primaryValue <= 0) {
      throw const ValidationFailure('Enter a valid measurement value.');
    }
    final double? secondary = vital.secondaryValue;
    if (secondary != null && (!secondary.isFinite || secondary <= 0)) {
      throw const ValidationFailure('Enter a valid measurement value.');
    }
  }
}