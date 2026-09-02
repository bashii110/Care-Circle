import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../errors/failures.dart';
import 'notification_service.dart';

/// [NotificationService] backed by `flutter_local_notifications`
/// (architecture.md §2, §11).
///
/// NOTE ON SANDBOX LIMITATIONS: this file was written without a working
/// Flutter SDK or network access to verify it against the actual
/// `flutter_local_notifications`/`timezone`/`flutter_timezone` package
/// APIs (see the project README). The overall structure — initialize,
/// create an Android channel, request permission, then use
/// `zonedSchedule` with `matchDateTimeComponents: DateTimeComponents.time`
/// for a daily-repeating local-time reminder — is the standard,
/// well-documented pattern for this plugin trio, but exact method/
/// parameter names can drift between package versions. Run
/// `flutter pub get` and `flutter analyze` locally and treat any errors
/// here as version-alignment fixes, not architectural problems.
class FlutterLocalNotificationsService implements NotificationService {
  FlutterLocalNotificationsService();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'medication_reminders';
  static const String _channelName = 'Medication Reminders';
  static const String _channelDescription = 'Reminders to take scheduled medications.';

  @override
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    await _configureLocalTimeZone();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _plugin.initialize(settings);

      final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );

      // Android 13+ requires runtime POST_NOTIFICATIONS permission;
      // iOS/macOS require an explicit permission request too. Per
      // srd.md FR-05, this happens when the app is initialized (which,
      // per main.dart, is effectively "at first launch after onboarding"
      // for most caregivers) rather than being buried in a settings menu.
      await androidPlugin?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      _initialized = true;
    } catch (_) {
      // Notifications are a best-effort enhancement, not a hard
      // dependency (srd.md — Reliability: "Failed notification
      // scheduling must not corrupt medication data"). Callers
      // (MedicationScheduler / MedicationNotifier) already treat a
      // thrown NotificationFailure as non-fatal.
      throw const NotificationFailure(
        "We couldn't set up medication reminders on this device.",
      );
    }
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // If the device's timezone can't be determined or isn't in the
      // `timezone` package's database, fall back to whatever `tz.local`
      // already defaults to (UTC) rather than crashing startup. This is
      // the practical limit on "Handle timezone/date changes" this phase
      // implements — see the README's Known Limitations.
    }
  }

  @override
  Future<void> scheduleMedicationReminder({
    required String medicationId,
    required String medicationName,
    required String dosage,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) return;

    final int id = medicationNotificationId(
      medicationId: medicationId,
      hour: hour,
      minute: minute,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        medicationName,
        'Time for $dosage',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        // Inexact-while-idle avoids Android 12+'s SCHEDULE_EXACT_ALARM
        // permission flow. A medication reminder landing a few minutes
        // off schedule is an acceptable trade-off for not requiring a
        // separate "Alarms & reminders" permission grant; upgrading to
        // exact alarms is a reasonable future enhancement, not a Phase 4
        // requirement.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      throw const NotificationFailure();
    }
  }

  @override
  Future<void> cancelMedicationReminder({
    required String medicationId,
    required int hour,
    required int minute,
  }) async {
    final int id = medicationNotificationId(
      medicationId: medicationId,
      hour: hour,
      minute: minute,
    );
    try {
      await _plugin.cancel(id);
    } catch (_) {
      throw const NotificationFailure("We couldn't cancel that reminder.");
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
