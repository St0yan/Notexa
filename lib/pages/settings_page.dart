import 'package:flutter/material.dart';
import 'home_controller.dart';

class SettingsPage extends StatelessWidget {
  final HomeController controller;

  const SettingsPage({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [

          // ===== ВЪНШЕН ВИД =====

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Външен вид',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text('Светла тема'),
            onTap: () {
              controller.setTheme(ThemeMode.light);
            },
          ),

          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Тъмна тема'),
            onTap: () {
              controller.setTheme(ThemeMode.dark);
            },
          ),

          ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: const Text('Системна тема'),
            onTap: () {
              controller.setTheme(ThemeMode.system);
            },
          ),

          const Divider(),

          // ===== СИГУРНОСТ =====

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Сигурност',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text(
              'Заключване на приложението',
            ),
            subtitle: const Text(
              'Изисквай отпечатък при отваряне',
            ),
            value: controller.lockEnabled,
            onChanged: (value) async {
              await controller.setLockEnabled(value);
            },
          ),

          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text(
              'Време до заключване',
            ),
            trailing: DropdownButton<int>(
              value: controller.lockTimeoutSeconds,
              items: const [
                DropdownMenuItem(
                  value: 0,
                  child: Text('Веднага'),
                ),
                DropdownMenuItem(
                  value: 30,
                  child: Text('30 сек'),
                ),
                DropdownMenuItem(
                  value: 60,
                  child: Text('1 минута'),
                ),
                DropdownMenuItem(
                  value: 300,
                  child: Text('5 минути'),
                ),
                DropdownMenuItem(
                  value: 900,
                  child: Text('15 минути'),
                ),
              ],
              onChanged: (value) async {
                if (value == null) return;

                await controller.setLockTimeout(
                  value,
                );
              },
            ),
          ),

          const Divider(),

          // ===== ДАННИ =====

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Данни',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Синхронизирай'),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Синхронизацията ще бъде добавена тук'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Експорт'),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Експортът ще бъде добавен тук'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Импорт'),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Импортът ще бъде добавен тук'),
                ),
              );
            },
          ),

          const Divider(),

          // ===== АКАУНТ =====

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Акаунт',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Вход с Google'),
            subtitle: const Text('Предстои'),
            onTap: () {},
          ),

          const Divider(),

          // ===== ЗА ПРИЛОЖЕНИЕТО =====

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Информация',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Notexa'),
            subtitle: Text('Версия 1.0.0'),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}