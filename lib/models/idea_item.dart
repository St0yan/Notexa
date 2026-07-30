import 'base_item.dart';

class IdeaItem extends BaseItem {
  final String text;

  IdeaItem({
    required super.id,
    required super.createdAt,
    required this.text,
  }) : super(type: ItemType.idea);
}