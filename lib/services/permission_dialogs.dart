import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

Future<void> showNotificationPermissionDialog(BuildContext context) async {
  final androidPlugin = NotificationService.plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  final granted = await androidPlugin?.areNotificationsEnabled() ?? false;

  if (granted) return;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Разреши известия'),
      content: const Text(
        'За да получаваш напомняния, трябва да разрешиш известията за приложението.',
      ),
      actions: [
        TextButton(
          child: const Text('Откажи'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Разреши'),
          onPressed: () async {
            Navigator.pop(context);
            await androidPlugin?.requestNotificationsPermission();
          },
        ),
      ],
    ),
  );
}

Future<void> showExactAlarmDialog(BuildContext context) async {
  final canSchedule = await NotificationService.canScheduleExactAlarms();

  if (canSchedule) return;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Разреши точни аларми'),
      content: const Text(
        'За да работят напомнянията точно навреме, трябва да разрешиш точните аларми.',
      ),
      actions: [
        TextButton(
          child: const Text('Откажи'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Разреши'),
          onPressed: () async {
            Navigator.pop(context);
            await NotificationService.requestExactAlarmPermission();
          },
        ),
      ],
    ),
  );
}
