import 'package:flutter/material.dart';
import 'home_controller.dart';
import 'home_page.dart';

class LockScreen extends StatefulWidget {
  final HomeController controller;
  final VoidCallback onUnlocked;

  const LockScreen({
    super.key,
    required this.controller,
    required this.onUnlocked,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _unlock();
    });
  }

  Future<void> _unlock() async {
    final unlocked =
        await widget.controller.authenticateUser();

    if (!mounted) return;

    if (unlocked) {
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Notexa е заключено',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.fingerprint),
              label: const Text('Отключи'),
              onPressed: _unlock,
            ),
          ],
        ),
      ),
    );
  }
}