import 'package:hive/hive.dart';

import '../../core/errors/failures.dart';
import '../models/care_models.dart';

abstract class MedicationRepository {
  List<Medication> getAll();
  Medication? getById(String id);
  Future<void> add(Medication medication);
  Future<void> update(Medication medication);
  Future<void> delete(String id);
}

class HiveMedicationRepository implements MedicationRepository {
  HiveMedicationRepository(this._box);

  final Box<Medication> _box;

  @override
  List<Medication> getAll() => _box.values.toList(growable: false);

  @override
  Medication? getById(String id) => _box.get(id);

  @override
  Future<void> add(Medication medication) async {
    _validate(medication);
    await _put(medication);
  }

  @override
  Future<void> update(Medication medication) async {
    _validate(medication);
    if (!_box.containsKey(medication.id)) {
      throw const ValidationFailure('That medication no longer exists.');
    }
    await _put(medication);
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  Future<void> _put(Medication medication) async {
    try {
      await _box.put(medication.id, medication);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  void _validate(Medication medication) {
    if (medication.name.trim().isEmpty) {
      throw const ValidationFailure('Medication name is required.');
    }
    if (medication.dosage.trim().isEmpty) {
      throw const ValidationFailure('Dosage is required.');
    }
    if (medication.alarmHours.isEmpty ||
        medication.alarmHours.length != medication.alarmMinutes.length) {
      throw const ValidationFailure(
        'At least one reminder time is required, with matching hours and minutes.',
      );
    }
    if (medication.alarmHours.any((int h) => h < 0 || h > 23) ||
        medication.alarmMinutes.any((int m) => m < 0 || m > 59)) {
      throw const ValidationFailure('Enter valid reminder times.');
    }
  }
}