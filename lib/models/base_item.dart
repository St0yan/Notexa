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

@HiveType(typeId: 100)
class BaseItem {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final ItemType type;
  @HiveField(2)
  final DateTime createdAt;

  BaseItem({
    required this.id,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'data': toDataJson(),
    };
  }

  Map<String, dynamic> toDataJson() {
    return {};
  }
}