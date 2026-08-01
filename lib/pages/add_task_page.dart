import 'package:flutter/material.dart';
import '../models/task_item.dart';

class AddTaskPage extends StatefulWidget {
  final TaskItem? editItem;

  const AddTaskPage({this.editItem, super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final List<TaskEntry> entries = [];
  final TextEditingController _entryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Ако редактираме → попълваме заглавието
    if (widget.editItem != null) {
      _titleCtrl.text = widget.editItem!.title;

      // Копираме entries, за да не променяме оригинала
      entries.addAll(
        widget.editItem!.entries.map(
          (e) => TaskEntry(text: e.text, isDone: e.isDone),
        ),
      );
    }
  }

  void _addEntry() {
    if (_entryCtrl.text.trim().isEmpty) return;

    setState(() {
      entries.add(TaskEntry(text: _entryCtrl.text.trim()));
      _entryCtrl.clear();
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
              final task = TaskItem(
                id: widget.editItem?.id ?? UniqueKey().toString(),
                createdAt: widget.editItem?.createdAt ?? DateTime.now(),
                title: _titleCtrl.text,
                entries: entries,
              );

              Navigator.pop(context, task);
            }
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: "Заглавие на задачата...",
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _entryCtrl,
                    decoration: const InputDecoration(
                      hintText: "Добави под‑задача...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addEntry,
                )
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      const Icon(Icons.circle_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(entries[index].text),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}