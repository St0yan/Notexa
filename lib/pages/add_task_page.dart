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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Задачата е запазена!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  margin: EdgeInsets.all(12),
                ),
              );
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
              textCapitalization: TextCapitalization.sentences,
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
                    textCapitalization: TextCapitalization.sentences,
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
                  final entry = entries[index];
                  final controller = TextEditingController(text: entry.text);

                  return Row(
                    children: [
                      // Чекбокс
                      Checkbox(
                        value: entry.isDone,
                        onChanged: (value) {
                          setState(() {
                            entry.isDone = value!;
                          });
                        },
                      ),

                      // Поле за редакция
                      Expanded(
                        child: TextField(
                          controller: controller,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            entry.text = value;
                          },
                        ),
                      ),

                      // Бутон за изтриване
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            entries.removeAt(index);
                          });
                        },
                      ),
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