import 'base_item.dart';

class GoalItem extends BaseItem {
  final String title;
  final String text;

  GoalItem({
    required super.id,
    required super.createdAt,
    required this.title,
    required this.text,
  }) : super(type: ItemType.goal);
}