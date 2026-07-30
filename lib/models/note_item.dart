import 'base_item.dart';

class NoteItem extends BaseItem {
  final String title;
  final String text;

  NoteItem({
    required super.id,
    required super.createdAt,
    required this.title,
    required this.text,
  }) : super(type: ItemType.note);
}