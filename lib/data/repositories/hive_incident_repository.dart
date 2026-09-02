import 'package:hive/hive.dart';

import '../../core/errors/failures.dart';
import '../models/care_models.dart';
import '../models/care_validators.dart';
import 'incident_repository.dart';

/// [IncidentRepository] backed by a Hive [Box].
class HiveIncidentRepository implements IncidentRepository {
  HiveIncidentRepository(this._box);

  final Box<IncidentLog> _box;

  @override
  Future<List<IncidentLog>> getAll() async {
    try {
      final List<IncidentLog> all = _box.values.toList();
      all.sort((IncidentLog a, IncidentLog b) => b.timestamp.compareTo(a.timestamp));
      return all;
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<IncidentLog?> getById(String id) async {
    try {
      return _box.get(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> add(IncidentLog incident) async {
    final String? error = CareValidators.validateIncidentLog(incident);
    if (error != null) throw ValidationFailure(error);

    try {
      await _box.put(incident.id, incident);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> update(IncidentLog incident) async {
    final String? error = CareValidators.validateIncidentLog(incident);
    if (error != null) throw ValidationFailure(error);

    if (!_box.containsKey(incident.id)) {
      throw const StorageFailure('That incident no longer exists.');
    }

    try {
      await _box.put(incident.id, incident);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const StorageFailure('That incident no longer exists.');
    }
    try {
      await _box.delete(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }
}
