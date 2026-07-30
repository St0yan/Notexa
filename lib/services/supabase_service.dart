import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/base_item.dart';
import '../models/note_item.dart';
import '../models/task_item.dart';
import '../models/idea_item.dart';
import '../models/reminder_item.dart';
import '../models/goal_item.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<void> uploadItem(BaseItem item) async {
    await supabase.from('items').insert({
      'id': item.id,
      'type': item.type.name,
      'created_at': item.createdAt.toIso8601String(),
      'data': _encodeItem(item),
    });
  }

  Map<String, dynamic> _encodeItem(BaseItem item) {
    switch (item.type) {
      case ItemType.note:
        final n = item as NoteItem;
        return {
          'title': n.title,
          'text': n.text,
        };

      case ItemType.task:
        final t = item as TaskItem;
        return {
          'title': t.title,
          'entries': t.entries
              .map((e) => {'text': e.text, 'isDone': e.isDone})
              .toList(),
        };

      case ItemType.idea:
        final i = item as IdeaItem;
        return {'text': i.text};

      case ItemType.reminder:
        final r = item as ReminderItem;
        return {
          'text': r.text,
          'alarm': r.alarmTime.toIso8601String(),
        };

      case ItemType.goal:
        final g = item as GoalItem;
        return {
          'title': g.title,
          'text': g.text,
        };
    }
  }

  BaseItem decodeItem(Map<String, dynamic> row) {
    final id = row['id'];
    final type = row['type'];
    final createdAt = DateTime.parse(row['created_at']);
    final data = row['data'] as Map<String, dynamic>;

    switch (type) {
      case 'note':
        return NoteItem(
          id: id,
          createdAt: createdAt,
          title: data['title'],
          text: data['text'],
        );

      case 'task':
        return TaskItem(
          id: id,
          createdAt: createdAt,
          title: data['title'],
          entries: (data['entries'] as List)
              .map((e) => TaskEntry(
                    text: e['text'],
                    isDone: e['isDone'],
                  ))
              .toList(),
        );

      case 'idea':
        return IdeaItem(
          id: id,
          createdAt: createdAt,
          text: data['text'],
        );

      case 'reminder':
        return ReminderItem(
          id: id,
          createdAt: createdAt,
          text: data['text'],
          alarmTime: DateTime.parse(data['alarm']),
        );

      case 'goal':
        return GoalItem(
          id: id,
          createdAt: createdAt,
          title: data['title'],
          text: data['text'],
        );

      default:
        throw Exception("Unknown item type: $type");
    }
  }
}