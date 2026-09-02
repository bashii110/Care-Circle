import '../models/care_models.dart';

/// Repository interface for [Medication] records.
abstract interface class MedicationRepository {
  Future<List<Medication>> getAll();

  Future<Medication?> getById(String id);

  /// Throws a `ValidationFailure` if [medication] fails validation, or a
  /// `StorageFailure` if the write itself fails.
  Future<void> add(Medication medication);

  /// Throws a `ValidationFailure` if [medication] fails validation, or a
  /// `StorageFailure` if no medication with that id exists or the write fails.
  Future<void> update(Medication medication);

  /// Throws a `StorageFailure` if no medication with [id] exists.
  Future<void> delete(String id);
}
