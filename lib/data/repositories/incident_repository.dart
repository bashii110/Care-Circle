import '../models/care_models.dart';

/// Repository interface for [IncidentLog] records.
abstract interface class IncidentRepository {
  /// All incidents, most recent first — matching the historical feed's
  /// natural reading order (design.md §10).
  Future<List<IncidentLog>> getAll();

  Future<IncidentLog?> getById(String id);

  /// Throws a `ValidationFailure` if [incident] fails validation, or a
  /// `StorageFailure` if the write itself fails.
  Future<void> add(IncidentLog incident);

  /// Throws a `ValidationFailure` if [incident] fails validation, or a
  /// `StorageFailure` if no incident with that id exists or the write fails.
  Future<void> update(IncidentLog incident);

  /// Throws a `StorageFailure` if no incident with [id] exists.
  Future<void> delete(String id);
}
