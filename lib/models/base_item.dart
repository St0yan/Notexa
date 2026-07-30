import 'package:hive/hive.dart';

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

abstract class BaseItem {
  final String id;
  final ItemType type;
  final DateTime createdAt;

  BaseItem({
    required this.id,
    required this.type,
    required this.createdAt,
  });
}