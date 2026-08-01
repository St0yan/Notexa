import 'package:hive/hive.dart';
import 'base_item.dart';

part 'task_item.g.dart';

@HiveType(typeId: 2)
class TaskEntry {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool isDone;

  TaskEntry({
    required this.text,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isDone': isDone,
    };
  }

  factory TaskEntry.fromJson(Map<String, dynamic> json) {
    return TaskEntry(
      text: json['text'],
      isDone: json['isDone'] ?? false,
    );
  }
}

@HiveType(typeId: 3)
class TaskItem extends BaseItem {
  @HiveField(3)
  final String title;

  @HiveField(4)
  final List<TaskEntry> entries;

  TaskItem({
    required super.id,
    required super.createdAt,
    required this.title,
    required this.entries,
  }) : super(type: ItemType.task);

  @override
  Map<String, dynamic> toDataJson() {
    return {
      'id': id,
      'title': title,
      'entries': entries.map((e) => {
        'text': e.text,
        'isDone': e.isDone,
      }).toList(),
      'created_at': createdAt.toIso8601String(),
      'type': type.name,
    };
  }
}