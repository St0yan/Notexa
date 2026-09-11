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
    const AndroidInitializationSettings('notify_icon');

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
            icon: 'notify_icon',
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction('snooze_15m', 'Отлагане 15 мин', showsUserInterface: true),
              AndroidNotificationAction('snooze_30m', 'Отлагане 30 мин', showsUserInterface: true),
              AndroidNotificationAction('snooze_1h', 'Отлагане 1 час', showsUserInterface: true),
              AndroidNotificationAction('snooze_2h', 'Отлагане 2 часа', showsUserInterface: true),
              AndroidNotificationAction('snooze_tomorrow', 'До утре сутрин', showsUserInterface: true),
              AndroidNotificationAction('snooze_monday', 'До понеделник', showsUserInterface: true),
              AndroidNotificationAction('mark_done', 'Изпълнено', showsUserInterface: true),
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
    final itemId = response.payload;

    if (actionId == 'snooze_15m') {
      _handleSnooze(itemId, const Duration(minutes: 15));
    } else if (actionId == 'snooze_30m') {
      _handleSnooze(itemId, const Duration(minutes: 30));
    } else if (actionId == 'snooze_1h') {
      _handleSnooze(itemId, const Duration(hours: 1));
    } else if (actionId == 'snooze_2h') {
      _handleSnooze(itemId, const Duration(hours: 2));
    } else if (actionId == 'snooze_tomorrow') {
      _handleSnoozeTomorrow(itemId);
    } else if (actionId == 'snooze_monday') {
      _handleSnoozeMonday(itemId);
    } else if (actionId == 'mark_done') {
      _handleMarkDone(itemId);
    }
  }

  static Future<void> _handleSnooze(String? itemId, Duration duration) async {
    if (itemId == null) return;

    final newTime = DateTime.now().add(duration);

    HomeController.instance.updateReminderTime(itemId, newTime);

    final item = HomeController.instance.items.firstWhere((i) => i.id == itemId);
    await scheduleReminder(id: itemId, text: item.title, dateTime: newTime);
  }

  static Future<void> _handleSnoozeTomorrow(String? itemId) async {
    if (itemId == null) return;

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 8, 0);

    HomeController.instance.updateReminderTime(itemId, tomorrow);

    final item = HomeController.instance.items.firstWhere((i) => i.id == itemId);
    await scheduleReminder(id: itemId, text: item.title, dateTime: tomorrow);
  }

  static Future<void> _handleSnoozeMonday(String? itemId) async {
    if (itemId == null) return;

    final now = DateTime.now();
    int daysToMonday = (DateTime.monday - now.weekday) % 7;
    if (daysToMonday == 0) daysToMonday = 7; // ако е понеделник → следващия понеделник

    final monday = DateTime(now.year, now.month, now.day + daysToMonday, 8, 0);

    HomeController.instance.updateReminderTime(itemId, monday);

    final item = HomeController.instance.items.firstWhere((i) => i.id == itemId);
    await scheduleReminder(id: itemId, text: item.title, dateTime: monday);
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