import 'package:flutter/material.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final TextEditingController _textCtrl = TextEditingController();
  DateTime? alarm;

  Future<void> pickAlarm() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      alarm = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {
                'text': _textCtrl.text,
                'alarm': alarm,
              });
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textCtrl,
              decoration: const InputDecoration(
                hintText: "Напомняне...",
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Text(
                  alarm == null
                      ? "Няма избрана аларма"
                      : "Аларма: $alarm",
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.alarm),
                  onPressed: pickAlarm,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}