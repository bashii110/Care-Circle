import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/models/care_validators.dart';
import 'package:care_circle/data/repositories/medication_repository.dart';

/// A [MedicationRepository] backed by an in-memory map, for tests — the
/// medication-feature counterpart to `InMemoryProfileRepository`.
class InMemoryMedicationRepository implements MedicationRepository {
  InMemoryMedicationRepository({List<Medication> seed = const <Medication>[]})
      : _medications = <String, Medication>{
          for (final Medication medication in seed) medication.id: medication,
        };

  final Map<String, Medication> _medications;

  @override
  Future<List<Medication>> getAll() async => _medications.values.toList(growable: false);

  @override
  Future<Medication?> getById(String id) async => _medications[id];

  @override
  Future<void> add(Medication medication) async {
    final String? error = CareValidators.validateMedication(medication);
    if (error != null) throw ValidationFailure(error);
    _medications[medication.id] = medication;
  }

  @override
  Future<void> update(Medication medication) async {
    final String? error = CareValidators.validateMedication(medication);
    if (error != null) throw ValidationFailure(error);
    if (!_medications.containsKey(medication.id)) {
      throw const StorageFailure('That medication no longer exists.');
    }
    _medications[medication.id] = medication;
  }

  @override
  Future<void> delete(String id) async {
    if (!_medications.containsKey(id)) {
      throw const StorageFailure('That medication no longer exists.');
    }
    _medications.remove(id);
  }
}
