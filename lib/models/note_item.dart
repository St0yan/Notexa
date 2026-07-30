import 'package:hive/hive.dart';
import 'base_item.dart';

part 'note_item.g.dart';

@HiveType(typeId: 1)
class NoteItem extends BaseItem {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String text;

  NoteItem({
    required super.id,
    required super.createdAt,
    required this.title,
    required this.text,
  }) : super(type: ItemType.note);
}