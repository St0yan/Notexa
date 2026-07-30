import 'package:hive/hive.dart';
import 'base_item.dart';

part 'idea_item.g.dart';

@HiveType(typeId: 4)
class IdeaItem extends BaseItem {
  @HiveField(3)
  final String text;

  IdeaItem({
    required super.id,
    required super.createdAt,
    required this.text,
  }) : super(type: ItemType.idea);
}