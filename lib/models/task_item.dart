import 'package:hive/hive.dart';
import 'base_item.dart';

part 'task_item.g.dart';

@HiveType(typeId: 2)
class TaskEntry {
  @HiveField(3)
  String text;
  @HiveField(4)
  bool isDone;

  TaskEntry({
    required this.text,
    this.isDone = false,
  });
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
}