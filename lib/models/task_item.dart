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
}

@HiveType(typeId: 3)
class TaskItem extends BaseItem {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final List<TaskEntry> entries;

  TaskItem({
    required super.id,
    required super.createdAt,
    required this.title,
    required this.entries,
  }) : super(type: ItemType.task);
}