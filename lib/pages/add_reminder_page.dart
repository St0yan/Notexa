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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();

    if (widget.editItem != null) {
      _textCtrl.text = widget.editItem!.text;
      _selectedDate = widget.editItem!.alarmTime;
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _save() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Моля, изберете дата и час за напомнянето.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          margin: EdgeInsets.all(12),
        ),
      );
      return;
    }

    final combined = combineDateAndTime(_selectedDate!, _selectedTime!);

    final reminder = ReminderItem(
      id: widget.editItem?.id ?? UniqueKey().toString(),              // ✔ ако редактираме → запазва ID
      createdAt: widget.editItem?.createdAt ?? DateTime.now(),        // ✔ ако редактираме → запазва createdAt
      text: _textCtrl.text,
      alarmTime: combined,                                            // ✔ новата дата/час
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
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDate == null
                        ? "Избери дата"
                        : "Дата: ${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}",
                  ),
                ),
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