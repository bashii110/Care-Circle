import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/care_models.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/repository_providers.dart';

/// Owns the list of [SeniorProfile]s and their mutations
/// (architecture.md §6 — `profileNotifierProvider`).
///
/// [build] gives the UI Riverpod's standard `loading` / `data` / `error`
/// [AsyncValue] states for free (architecture.md §12); an "empty" state is
/// simply `data` with an empty list, which screens check for directly.
///
/// The mutation methods intentionally do *not* swallow the
/// `ValidationFailure`/`StorageFailure` a repository throws — they
/// propagate to the caller so a form can show the message inline right
/// where the caregiver is typing, instead of only surfacing through the
/// list's `error` state.
class ProfileNotifier extends AsyncNotifier<List<SeniorProfile>> {
  @override
  Future<List<SeniorProfile>> build() {
    return ref.watch(profileRepositoryProvider).getAll();
  }

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  Future<void> createProfile(SeniorProfile profile) async {
    await _repository.add(profile);
    state = AsyncData<List<SeniorProfile>>(await _repository.getAll());
  }

  Future<void> updateProfile(SeniorProfile profile) async {
    await _repository.update(profile);
    state = AsyncData<List<SeniorProfile>>(await _repository.getAll());
  }

  Future<void> deleteProfile(String id) async {
    await _repository.delete(id);
    state = AsyncData<List<SeniorProfile>>(await _repository.getAll());
  }
}

final AsyncNotifierProvider<ProfileNotifier, List<SeniorProfile>> profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, List<SeniorProfile>>(ProfileNotifier.new);

/// The senior currently shown across the app.
///
/// The free tier (srd.md §7) only ever has one profile, so this is simply
/// "the first profile that has loaded" for now. Real multi-profile
/// selection, backed by [PreferenceKeys.selectedProfileId], is exercised
/// starting with Phase 11 (Premium & RevenueCat) once a caregiver can
/// actually have more than one to choose between.
final Provider<SeniorProfile?> activeSeniorProfileProvider = Provider<SeniorProfile?>((ref) {
  final List<SeniorProfile> profiles =
      ref.watch(profileNotifierProvider).valueOrNull ?? const <SeniorProfile>[];
  if (profiles.isEmpty) return null;
  return profiles.first;
});
