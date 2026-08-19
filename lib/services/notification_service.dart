import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../pages/home_controller.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
      static FlutterLocalNotificationsPlugin get plugin => _plugin;

      static const platform = MethodChannel('exact_alarm_permission');

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Sofia'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: android,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        NotificationService.handleAction(response);
      },
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'reminder_channel',
        'Напомняния',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('notify_notexa'),
      ),
    );

    await androidPlugin?.requestNotificationsPermission();
    await requestExactAlarmPermission();
  }

  static Future<void> scheduleReminder({
    required String id,
    required String text,
    required DateTime dateTime,
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
      await _plugin.zonedSchedule(
        id: id.hashCode,
        title: 'Напомняне',
        body: text,
        payload: id,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Напомняния',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('notify_notexa'),
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                'snooze_1h',
                'Отлагане с 1 час',
                showsUserInterface: true,
              ),
              AndroidNotificationAction(
                'mark_done',
                'Изпълнено',
                showsUserInterface: true,
              ),
            ],
          ),
        ),
        scheduledDate: scheduledDate,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
  }

  static Future<void> cancelReminder(String id) async {
    await _plugin.cancel(id: id.hashCode);
  }

  static void handleAction(NotificationResponse response) async {
    final actionId = response.actionId;
    final payload = response.payload;

    if (actionId == 'snooze_1h') {
      _handleSnooze(payload);
    } else if (actionId == 'mark_done') {
      _handleMarkDone(payload);
    }
  }

  static Future<void> _handleSnooze(String? itemId) async {
    if (itemId == null) return;

    final now = DateTime.now();
    final newTime = now.add(const Duration(hours: 1));

    await scheduleReminder(
      id: itemId,
      text: 'Отложено напомняне',
      dateTime: newTime,
    );

    HomeController.instance.updateReminderTime(itemId, newTime);
  }

  static Future<void> _handleMarkDone(String? itemId) async {
    if (itemId == null) return;

    await _plugin.cancel(id: itemId.hashCode);

    HomeController.instance.deleteItemById(itemId);
  }

  static Future<void> requestExactAlarmPermission() async {
    try {
      await platform.invokeMethod('requestExactAlarmPermission');
    } catch (e) {
      print("Exact alarm permission error: $e");
    }
  }

  static Future<bool> canScheduleExactAlarms() async {
    try {
      return await platform.invokeMethod('canScheduleExactAlarms') == true;
    } catch (_) {
      return false;
    }
  }
}