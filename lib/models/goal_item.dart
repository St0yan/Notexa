import 'package:hive/hive.dart';
import 'base_item.dart';

part 'goal_item.g.dart';

@HiveType(typeId: 6)
class GoalItem extends BaseItem {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String text;

  GoalItem({
    required super.id,
    required super.createdAt,
    required this.title,
    required this.text,
  }) : super(type: ItemType.goal);
}