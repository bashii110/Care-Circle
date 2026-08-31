import 'package:hive/hive.dart';

import '../../core/errors/failures.dart';
import '../models/care_models.dart';

/// Read/write access to [SeniorProfile] records.
///
/// The UI and its Riverpod notifiers must depend on this interface, never
/// on [Hive] or [HiveProfileRepository] directly (architecture.md §3),
/// so screens can later be tested against a fake implementation.
abstract class ProfileRepository {
  List<SeniorProfile> getAll();
  SeniorProfile? getById(String id);
  Future<void> add(SeniorProfile profile);
  Future<void> update(SeniorProfile profile);
  Future<void> delete(String id);
}

class HiveProfileRepository implements ProfileRepository {
  HiveProfileRepository(this._box);

  final Box<SeniorProfile> _box;

  @override
  List<SeniorProfile> getAll() => _box.values.toList(growable: false);

  @override
  SeniorProfile? getById(String id) => _box.get(id);

  @override
  Future<void> add(SeniorProfile profile) async {
    _validate(profile);
    await _put(profile);
  }

  @override
  Future<void> update(SeniorProfile profile) async {
    _validate(profile);
    if (!_box.containsKey(profile.id)) {
      throw const ValidationFailure('That profile no longer exists.');
    }
    await _put(profile);
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  Future<void> _put(SeniorProfile profile) async {
    try {
      await _box.put(profile.id, profile);
    } catch (_) {
      throw const StorageFailure();
    }
  }

  void _validate(SeniorProfile profile) {
    if (profile.fullName.trim().isEmpty) {
      throw const ValidationFailure('Full name is required.');
    }
    if (profile.age <= 0 || profile.age > 130) {
      throw const ValidationFailure('Enter a valid age.');
    }
    if (profile.emergencyContactPhone.trim().isEmpty) {
      throw const ValidationFailure('Emergency contact phone is required.');
    }
  }
}