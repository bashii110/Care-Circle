import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/care_models.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../logic/medication_scheduler.dart';
import '../domain/medication_schedule.dart';

/// Owns the list of [Medication]s and their mutations
/// (architecture.md §6 — `medicationNotifierProvider`, with the exact
/// method set architecture.md §6 lists under `MedicationNotifier`).
///
/// Every mutation that changes a medication's schedule also reconciles
/// its OS-level reminders through [MedicationScheduler] (architecture.md
/// §13 — "Notification reconciliation should occur... whenever medication
/// data changes"). Those calls are always best-effort: a notification
/// failure is swallowed rather than surfaced, because failing to persist
/// or load medication data over a notification problem would violate
/// srd.md's reliability requirement ("Failed notification scheduling
/// must not corrupt medication data"). `main.dart` additionally performs
/// one eager, unconditional reconciliation pass at startup — see its
/// comments — since this notifier only reconciles when something in the
/// UI actually watches it.
class MedicationNotifier extends AsyncNotifier<List<Medication>> {
  @override
  Future<List<Medication>> build() async {
    final List<Medication> medications = await ref.watch(medicationRepositoryProvider).getAll();
    await _reconcileNotifications(medications);
    return medications;
  }

  MedicationRepository get _repository => ref.read(medicationRepositoryProvider);

  /// Re-fetches medications from the repository.
  Future<void> loadMedications() async {
    state = const AsyncLoading<List<Medication>>();
    state = await AsyncValue.guard(() async {
      final List<Medication> medications = await _repository.getAll();
      await _reconcileNotifications(medications);
      return medications;
    });
  }

  /// Adds [medication], enforcing the free-tier limit
  /// (phases.md Phase 3 — "Free-tier limit of three active medications").
  ///
  /// Throws a [ValidationFailure] if the limit is reached or [medication]
  /// fails validation, or a [StorageFailure] if the write itself fails.
  Future<void> addMedication(Medication medication) async {
    final List<Medication> current = state.valueOrNull ?? await _repository.getAll();
    if (current.length >= kFreeMedicationTierLimit) {
      throw const ValidationFailure(
        'The free plan supports up to $kFreeMedicationTierLimit medications. '
        'Remove one to add another.',
      );
    }
    await _repository.add(medication);
    await _tryScheduleAll(medication);
    state = AsyncData<List<Medication>>(await _repository.getAll());
  }

  Future<void> updateMedication(Medication medication) async {
    final Medication? previous = await _repository.getById(medication.id);
    await _repository.update(medication);
    if (previous != null) {
      await _tryReschedule(previous: previous, updated: medication);
    } else {
      await _tryScheduleAll(medication);
    }
    state = AsyncData<List<Medication>>(await _repository.getAll());
  }

  Future<void> deleteMedication(String id) async {
    final Medication? existing = await _repository.getById(id);
    await _repository.delete(id);
    if (existing != null) {
      await _tryCancelAll(existing);
    }
    state = AsyncData<List<Medication>>(await _repository.getAll());
  }

  /// Records that the dose scheduled at [scheduledAt] was taken.
  Future<void> markTaken(String medicationId, DateTime scheduledAt) =>
      _setCompliance(medicationId, scheduledAt, taken: true);

  /// Records that the dose scheduled at [scheduledAt] was explicitly
  /// skipped (as opposed to simply going unrecorded/overdue).
  Future<void> markSkipped(String medicationId, DateTime scheduledAt) =>
      _setCompliance(medicationId, scheduledAt, taken: false);

  Future<void> _setCompliance(
    String medicationId,
    DateTime scheduledAt, {
    required bool taken,
  }) async {
    final Medication? current = await _repository.getById(medicationId);
    if (current == null) {
      throw const StorageFailure('That medication no longer exists.');
    }

    final Map<String, bool> updatedHistory = Map<String, bool>.from(current.complianceHistory)
      ..[MedicationSchedule.complianceKeyFor(scheduledAt)] = taken;

    // Marking a dose taken/skipped doesn't change *when* future doses are
    // reminded — only whether today's already happened — so no
    // scheduler call is needed here, unlike add/update/delete.
    await _repository.update(current.copyWith(complianceHistory: updatedHistory));
    state = AsyncData<List<Medication>>(await _repository.getAll());
  }

  Future<void> _reconcileNotifications(List<Medication> medications) async {
    for (final Medication medication in medications) {
      await _tryScheduleAll(medication);
    }
  }

  Future<void> _tryScheduleAll(Medication medication) async {
    try {
      await ref.read(medicationSchedulerProvider).scheduleAll(medication);
    } catch (_) {
      // Best-effort — see class doc comment.
    }
  }

  Future<void> _tryCancelAll(Medication medication) async {
    try {
      await ref.read(medicationSchedulerProvider).cancelAll(medication);
    } catch (_) {
      // Best-effort — see class doc comment.
    }
  }

  Future<void> _tryReschedule({required Medication previous, required Medication updated}) async {
    try {
      await ref.read(medicationSchedulerProvider).reschedule(previous: previous, updated: updated);
    } catch (_) {
      // Best-effort — see class doc comment.
    }
  }
}

final AsyncNotifierProvider<MedicationNotifier, List<Medication>> medicationNotifierProvider =
    AsyncNotifierProvider<MedicationNotifier, List<Medication>>(MedicationNotifier.new);
