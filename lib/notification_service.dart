import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ── INITIALIZE
  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // request permission on Android 13+
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    _initialized = true;
  }

  // ── SCHEDULE DAILY NOTIFICATION
  static Future<void> scheduleDailyQuote({
    required String quote,
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      'DONT GOON, YOU FUCKING GOONER 🤡',
      quote,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quote_channel',
          'Daily Quote',
          channelDescription: 'Daily motivational quote',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // // ── INSTANT NOTIFICATION (test)
  // static Future<void> showInstant() async {
  //   await _plugin.show(
  //     1,
  //     'Gooner Detected 🤡',
  //     'Put that phone down and stay strong.',
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'instant_channel',
  //         'Instant',
  //         channelDescription: 'Instant notifications',
  //         importance: Importance.high,
  //         priority: Priority.high,
  //         icon: '@mipmap/ic_launcher',
  //       ),
  //     ),
  //   );
  // }

  // ── CANCEL ALL
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
