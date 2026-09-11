import 'package:hive/hive.dart';
import 'goal_item.dart';
import 'idea_item.dart';
import 'note_item.dart';
import 'reminder_item.dart';
import 'task_item.dart';

part 'base_item.g.dart';

@HiveType(typeId: 0)
enum ItemType {
  @HiveField(0)
  note,
  @HiveField(1)
  task,
  @HiveField(2)
  idea,
  @HiveField(3)
  reminder,
  @HiveField(4)
  goal,
}

@HiveType(typeId: 100)
class BaseItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final ItemType type;

  @HiveField(2)
  final DateTime createdAt;

  // 🔥 нови полета за offline-first
  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  bool isDeleted;

  @HiveField(5)
  bool isSynced;

  BaseItem({
    required this.id,
    required this.type,
    required this.createdAt,
    DateTime? updatedAt,
    this.isDeleted = false,
    this.isSynced = true,
  }) : updatedAt = updatedAt ?? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
      'is_synced': isSynced,
      'data': toDataJson(),
    };
  }

  Map<String, dynamic> toDataJson() {
    return {};
  }

  String get title {
    if (this is NoteItem) return (this as NoteItem).text;
    if (this is TaskItem) return (this as TaskItem).title;
    if (this is IdeaItem) return (this as IdeaItem).text;
    if (this is GoalItem) return (this as GoalItem).text;
    if (this is ReminderItem) return (this as ReminderItem).text;

    return "";
  }
}