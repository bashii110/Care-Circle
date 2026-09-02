import 'package:hive/hive.dart';

import '../../core/errors/failures.dart';
import '../models/care_models.dart';
import '../models/care_validators.dart';
import 'medication_repository.dart';

/// [MedicationRepository] backed by a Hive [Box].
///
/// Note: this only manages the `Medication` records themselves (name,
/// dosage, reminder times, compliance history). Turning a medication into
/// scheduled OS notifications is a separate concern, owned by the
/// `MedicationScheduler` introduced in Phase 4 (architecture.md §8) — this
/// repository has no knowledge of `flutter_local_notifications`.
class HiveMedicationRepository implements MedicationRepository {
  HiveMedicationRepository(this._box);

  final Box<Medication> _box;

  @override
  Future<List<Medication>> getAll() async {
    try {
      return _box.values.toList(growable: false);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<Medication?> getById(String id) async {
    try {
      return _box.get(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> add(Medication medication) async {
    final String? error = CareValidators.validateMedication(medication);
    if (error != null) throw ValidationFailure(error);

    try {
      await _box.put(medication.id, medication);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> update(Medication medication) async {
    final String? error = CareValidators.validateMedication(medication);
    if (error != null) throw ValidationFailure(error);

    if (!_box.containsKey(medication.id)) {
      throw const StorageFailure('That medication no longer exists.');
    }

    try {
      await _box.put(medication.id, medication);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const StorageFailure('That medication no longer exists.');
    }
    try {
      await _box.delete(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }
}
