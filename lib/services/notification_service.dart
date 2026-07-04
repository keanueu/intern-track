import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static const _shiftReminderId = 1000;

  Future<void> scheduleShiftReminders(
      List<Map<String, dynamic>> shifts) async {
    await cancelAll();

    final now = DateTime.now();
    final location = tz.local;

    for (final shift in shifts) {
      final dayOfWeek = shift['day_of_week'] as int;
      final startTime = shift['start_time'] as String;
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Schedule for the next occurrence of this day
      final nextDate = _nextDayOfWeek(now, dayOfWeek);
      final scheduledDate = DateTime(
        nextDate.year,
        nextDate.month,
        nextDate.day,
        hour,
        minute - 5, // 5 minutes before shift start
      );

      // If the time has passed today, skip to next week
      if (scheduledDate.isBefore(now)) {
        final nextWeek = scheduledDate.add(const Duration(days: 7));
        final tzScheduled = tz.TZDateTime.from(nextWeek, location);
        _scheduleWeekly(
          _shiftReminderId + dayOfWeek,
          'Shift Starting Soon',
          'Your shift starts in 5 minutes',
          tzScheduled,
        );
      } else {
        final tzScheduled = tz.TZDateTime.from(scheduledDate, location);
        _scheduleWeekly(
          _shiftReminderId + dayOfWeek,
          'Shift Starting Soon',
          'Your shift starts in 5 minutes',
          tzScheduled,
        );
      }
    }
  }

  void _scheduleWeekly(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledDate,
  ) {
    _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'shift_reminders',
          'Shift Reminders',
          channelDescription: 'Reminders before your shift starts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  DateTime _nextDayOfWeek(DateTime from, int targetDayOfWeek) {
    final current = from.weekday - 1;
    final daysUntil = (targetDayOfWeek - current + 7) % 7;
    return from.add(Duration(days: daysUntil == 0 ? 7 : daysUntil));
  }
}
