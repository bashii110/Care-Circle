import 'package:care_circle/core/services/notification_service.dart';

/// Records what was scheduled/cancelled, for testing [MedicationScheduler]
/// without touching real platform channels.
class FakeNotificationService implements NotificationService {
  final Map<int, ({String medicationId, int hour, int minute})> scheduled =
      <int, ({String medicationId, int hour, int minute})>{};
  final Set<int> cancelled = <int>{};
  bool initCalled = false;

  @override
  Future<void> init() async {
    initCalled = true;
  }

  @override
  Future<void> scheduleMedicationReminder({
    required String medicationId,
    required String medicationName,
    required String dosage,
    required int hour,
    required int minute,
  }) async {
    final int id = medicationNotificationId(medicationId: medicationId, hour: hour, minute: minute);
    scheduled[id] = (medicationId: medicationId, hour: hour, minute: minute);
  }

  @override
  Future<void> cancelMedicationReminder({
    required String medicationId,
    required int hour,
    required int minute,
  }) async {
    final int id = medicationNotificationId(medicationId: medicationId, hour: hour, minute: minute);
    scheduled.remove(id);
    cancelled.add(id);
  }
}
