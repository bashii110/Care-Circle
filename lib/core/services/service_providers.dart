import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'emergency_call_service.dart';
import 'notification_service.dart';

/// Provides the app's [NotificationService] (architecture.md §6 —
/// `notificationServiceProvider`).
///
/// Left unimplemented by default, matching `preferencesServiceProvider`
/// and the repository providers — `main.dart` overrides this with a real
/// `FlutterLocalNotificationsService` once it has been initialized. Tests
/// that exercise `MedicationScheduler`/`MedicationNotifier` directly can
/// override it with a fake `NotificationService`; tests that don't care
/// about notifications at all can simply leave it unoverridden, since
/// every real call site treats a notification failure as non-fatal.
final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((ref) {
  throw UnimplementedError(
    'notificationServiceProvider must be overridden before the app is run.',
  );
});

/// Provides the app's [EmergencyCallService] (Phase 5, srd.md FR-09).
final Provider<EmergencyCallService> emergencyCallServiceProvider =
    Provider<EmergencyCallService>((ref) {
  throw UnimplementedError(
    'emergencyCallServiceProvider must be overridden before the app is run.',
  );
});
