import 'package:hive/hive.dart';
import 'base_item.dart';

part 'note_item.g.dart';

@HiveType(typeId: 1)
class NoteItem extends BaseItem {
  @override
  @HiveField(3)
  final String title;
  @HiveField(4)
  final String text;

  NoteItem({
    required super.id,
    required super.createdAt,
    required this.title,
    required this.text,
  }) : super(type: ItemType.note);

  @override
  Map<String, dynamic> toDataJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'type': type.name,
    };
  }
}