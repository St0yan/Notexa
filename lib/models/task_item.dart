import 'base_item.dart';

class TaskEntry {
  String text;
  bool isDone;

  TaskEntry({
    required this.text,
    this.isDone = false,
  });
}

class TaskItem extends BaseItem {
  final String title;
  final List<TaskEntry> entries;

  TaskItem({
    required super.id,
    required super.createdAt,
    required this.title,
    required this.entries,
  }) : super(type: ItemType.task);
}