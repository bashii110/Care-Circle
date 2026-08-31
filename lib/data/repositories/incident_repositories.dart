import 'package:hive/hive.dart';

import '../../core/errors/failures.dart';
import '../models/care_models.dart';

abstract class IncidentRepository {
  List<IncidentLog> getAll();
  IncidentLog? getById(String id);
  Future<void> add(IncidentLog incident);
  Future<void> update(IncidentLog incident);
  Future<void> delete(String id);
}

class HiveIncidentRepository implements IncidentRepository {
  HiveIncidentRepository(this._box);

  final Box<IncidentLog> _box;

  @override
  List<IncidentLog> getAll() => _box.values.toList(growable: false);

  @override
  IncidentLog? getById(String id) => _box.get(id);

  @override
  Future<void> add(IncidentLog incident) async {
    _validate(incident);
    await _put(incident);
  }

  @override
  Future<void> update(IncidentLog incident) async {
    _validate(incident);
    if (!_box.containsKey(incident.id)) {
      throw const ValidationFailure('That incident no longer exists.');
    }
    await _put(incident);
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  Future<void> _put(IncidentLog incident) async {
    try {
      await _box.put(incident.id, incident);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  void _validate(IncidentLog incident) {
    if (!IncidentSeverity.all.contains(incident.severity)) {
      throw const ValidationFailure('Select a severity.');
    }
    if (incident.behaviorTags.trim().isEmpty) {
      throw const ValidationFailure('Select at least one behavior.');
    }
  }
}