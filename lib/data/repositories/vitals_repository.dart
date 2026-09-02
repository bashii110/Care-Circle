import '../models/care_models.dart';

/// Repository interface for [HealthVital] records.
abstract interface class VitalsRepository {
  Future<List<HealthVital>> getAll();

  /// All vitals of [type] recorded between [from] and [to] (inclusive),
  /// sorted oldest to newest. Used by the 7/30-day chart views in Phase 6
  /// — filtering happens here, at the repository, so chart widgets never
  /// query more data than the selected time range needs
  /// (srd.md §5 — "Charts should only query the selected time range").
  Future<List<HealthVital>> getByTypeInRange(
    VitalType type, {
    required DateTime from,
    required DateTime to,
  });

  Future<HealthVital?> getById(String id);

  /// Throws a `ValidationFailure` if [vital] fails validation, or a
  /// `StorageFailure` if the write itself fails.
  Future<void> add(HealthVital vital);

  /// Throws a `ValidationFailure` if [vital] fails validation, or a
  /// `StorageFailure` if no vital with that id exists or the write fails.
  Future<void> update(HealthVital vital);

  /// Throws a `StorageFailure` if no vital with [id] exists.
  Future<void> delete(String id);
}
