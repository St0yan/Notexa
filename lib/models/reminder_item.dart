import 'base_item.dart';

class ReminderItem extends BaseItem {
  final String text;
  final DateTime alarmTime;

  ReminderItem({
    required super.id,
    required super.createdAt,
    required this.text,
    required this.alarmTime,
  }) : super(type: ItemType.reminder);
}