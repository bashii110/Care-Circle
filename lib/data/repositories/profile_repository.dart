import '../models/care_models.dart';

/// Repository interface for [SeniorProfile] records.
///
/// UI and Riverpod notifiers depend on this interface, never on
/// `HiveProfileRepository` directly (architecture.md §3), so the storage
/// backend can change later (e.g. for cloud sync — architecture.md §15)
/// without touching the presentation layer.
abstract interface class ProfileRepository {
  Future<List<SeniorProfile>> getAll();

  Future<SeniorProfile?> getById(String id);

  /// Validates and persists a new profile.
  ///
  /// Throws a `ValidationFailure` if [profile] fails validation, or a
  /// `StorageFailure` if the write itself fails.
  Future<void> add(SeniorProfile profile);

  /// Validates and persists changes to an existing profile.
  ///
  /// Throws a `ValidationFailure` if [profile] fails validation, or a
  /// `StorageFailure` if no profile with that id exists or the write fails.
  Future<void> update(SeniorProfile profile);

  /// Throws a `StorageFailure` if no profile with [id] exists.
  Future<void> delete(String id);
}
