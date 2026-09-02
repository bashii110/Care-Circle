import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/models/care_validators.dart';
import 'package:care_circle/data/repositories/profile_repository.dart';

/// A [ProfileRepository] backed by an in-memory map, for tests that need a
/// fast, dependency-free stand-in for [HiveProfileRepository].
///
/// It intentionally applies the same [CareValidators] and existence checks
/// the real Hive-backed implementation does, so a test exercising this
/// fake still catches a widget that isn't handling `ValidationFailure`/
/// `StorageFailure` correctly.
class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository({List<SeniorProfile> seed = const <SeniorProfile>[]})
      : _profiles = <String, SeniorProfile>{
          for (final SeniorProfile profile in seed) profile.id: profile,
        };

  final Map<String, SeniorProfile> _profiles;

  @override
  Future<List<SeniorProfile>> getAll() async => _profiles.values.toList(growable: false);

  @override
  Future<SeniorProfile?> getById(String id) async => _profiles[id];

  @override
  Future<void> add(SeniorProfile profile) async {
    final String? error = CareValidators.validateSeniorProfile(profile);
    if (error != null) throw ValidationFailure(error);
    _profiles[profile.id] = profile;
  }

  @override
  Future<void> update(SeniorProfile profile) async {
    final String? error = CareValidators.validateSeniorProfile(profile);
    if (error != null) throw ValidationFailure(error);
    if (!_profiles.containsKey(profile.id)) {
      throw const StorageFailure('That profile no longer exists.');
    }
    _profiles[profile.id] = profile;
  }

  @override
  Future<void> delete(String id) async {
    if (!_profiles.containsKey(id)) {
      throw const StorageFailure('That profile no longer exists.');
    }
    _profiles.remove(id);
  }
}
