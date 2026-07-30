import 'package:flutter/material.dart';
import '/services/supabase_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/base_item.dart';
import '/models/note_item.dart';
import '/models/task_item.dart';
import '/models/idea_item.dart';
import '/models/reminder_item.dart';
import '/models/goal_item.dart';
import 'add_goal_page.dart';
import 'add_idea_page.dart';
import 'add_note_page.dart';
import 'add_reminder_page.dart';
import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabaseService = SupabaseService();
  final List<BaseItem> items = [];
  late Box<BaseItem> box;

  @override
  void initState() {
    super.initState();
    box = Hive.box<BaseItem>('items');
    items.addAll(box.values);

    _loadFromSupabase();
  }

  Future<void> _loadFromSupabase() async {
    final data = await Supabase.instance.client
        .from('items')
        .select();
    
    for (final row in data) {
      final item = supabaseService.decodeItem(row);
      if (!items.any((i) => i.id == item.id)) {
        items.add(item);
        box.add(item);
      }
    }

    setState(() {});
  }

  void _openAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption("Бележка", AddNotePage(), ItemType.note),
            _buildOption("Задача", AddTaskPage(), ItemType.task),
            _buildOption("Идея", AddIdeaPage(), ItemType.idea),
            _buildOption("Напомняне", AddReminderPage(), ItemType.reminder),
            _buildOption("Цел", AddGoalPage(), ItemType.goal),
          ],
        );
      },
    );
  }

  Widget _buildOption(String label, Widget page, ItemType type) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 18)),
      onTap: () async {
        Navigator.pop(context);

        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
        if (result != null) {
          setState(() {
            final item = _createItem(type, result);
            items.add(item);
            box.add(item);
            supabaseService.uploadItem(item);
          });
        }
      },
    );
  }

  BaseItem _createItem(ItemType type, dynamic data) {
    final id = UniqueKey().toString();
    final now = DateTime.now();

    switch (type) {
      case ItemType.note:
        return NoteItem(
          id: id,
          createdAt: now,
          title: data['title'],
          text: data['text'],
        );

      case ItemType.task:
        return TaskItem(
          id: id,
          createdAt: now,
          title: data['title'],
          entries: data['entries'],
        );

      case ItemType.idea:
        return IdeaItem(
          id: id,
          createdAt: now,
          text: data['text'],
        );

      case ItemType.reminder:
        return ReminderItem(
          id: id,
          createdAt: now,
          text: data['text'],
          alarmTime: data['alarm'],
        );

      case ItemType.goal:
        return GoalItem(
          id: id,
          createdAt: now,
          title: data['title'],
          text: data['text'],
        );
    }
  }

  Widget buildItemCard(BaseItem item) {
    switch (item.type) {
      case ItemType.note:
        final n = item as NoteItem;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(n.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(n.text, style: const TextStyle(fontSize: 16)),
          ],
        );

      case ItemType.task:
        final t = item as TaskItem;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...t.entries.map((entry) {
              return Row(
                children: [
                  Checkbox(
                    value: entry.isDone,
                    onChanged: (_) {},
                  ),
                  Text(entry.text),
                ],
              );
            }).toList(),
          ],
        );

      case ItemType.idea:
        final i = item as IdeaItem;
        return Text(i.text, style: const TextStyle(fontSize: 18));

      case ItemType.reminder:
        final r = item as ReminderItem;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.text, style: const TextStyle(fontSize: 18)),
            Text("⏰ ${r.alarmTime}",
                style: const TextStyle(color: Colors.grey)),
          ],
        );

      case ItemType.goal:
        final g = item as GoalItem;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(g.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(g.text, style: const TextStyle(fontSize: 16)),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.search, size: 26),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 26),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: buildItemCard(items[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMenu,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      )
    );
  }
}