import 'package:hive/hive.dart';
import 'base_item.dart';

part 'reminder_item.g.dart';

@HiveType(typeId: 5)
class ReminderItem extends BaseItem {
  @HiveField(0)
  final String text;
  @HiveField(1)
  final DateTime alarmTime;

  ReminderItem({
    required super.id,
    required super.createdAt,
    required this.text,
    required this.alarmTime,
  }) : super(type: ItemType.reminder);
}