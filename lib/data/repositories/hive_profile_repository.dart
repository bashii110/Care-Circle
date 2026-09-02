import 'package:hive/hive.dart';

import '../../core/errors/failures.dart';
import '../models/care_models.dart';
import '../models/care_validators.dart';
import 'profile_repository.dart';

/// [ProfileRepository] backed by a Hive [Box].
///
/// This is the only class allowed to touch the profile [Box] directly
/// (architecture.md §3 / §16 rule 2) — everything above this, including
/// Riverpod notifiers, goes through [ProfileRepository].
class HiveProfileRepository implements ProfileRepository {
  HiveProfileRepository(this._box);

  final Box<SeniorProfile> _box;

  @override
  Future<List<SeniorProfile>> getAll() async {
    try {
      return _box.values.toList(growable: false);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<SeniorProfile?> getById(String id) async {
    try {
      return _box.get(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> add(SeniorProfile profile) async {
    final String? error = CareValidators.validateSeniorProfile(profile);
    if (error != null) throw ValidationFailure(error);

    try {
      await _box.put(profile.id, profile);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> update(SeniorProfile profile) async {
    final String? error = CareValidators.validateSeniorProfile(profile);
    if (error != null) throw ValidationFailure(error);

    if (!_box.containsKey(profile.id)) {
      throw const StorageFailure('That profile no longer exists.');
    }

    try {
      await _box.put(profile.id, profile);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const StorageFailure('That profile no longer exists.');
    }
    try {
      await _box.delete(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }
}
