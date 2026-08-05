import 'package:flutter/material.dart';
import '../models/reminder_item.dart';

class AddReminderPage extends StatefulWidget {
  final ReminderItem? editItem;

  const AddReminderPage({this.editItem, super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final TextEditingController _textCtrl = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();

    if (widget.editItem != null) {
      _textCtrl.text = widget.editItem!.text;
      _selectedTime = _parseTime(widget.editItem!.alarmTime);
    }
  }

  TimeOfDay? _parseTime(DateTime? time) {
    if (time == null) return null;
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _save() {
    final now = DateTime.now();

    final reminder = ReminderItem(
      id: UniqueKey().toString(),
      createdAt: now,
      text: _textCtrl.text,
      alarmTime: _selectedTime != null
        ? DateTime(
            now.year,
            now.month,
            now.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          )
        : DateTime.now()
    );

    Navigator.pop(context, reminder);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Напомнянето е запазено!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.all(12),
      ),
    );
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
            onPressed: _save,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textCtrl,
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "Напомняне...",
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.alarm),
                  label: Text(
                    _selectedTime == null
                        ? "Избери час"
                        : "Час: ${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}