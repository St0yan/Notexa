import 'package:hive/hive.dart';
import 'base_item.dart';

part 'reminder_item.g.dart';

@HiveType(typeId: 5)
class ReminderItem extends BaseItem {
  @HiveField(3)
  final String text;
  @HiveField(4)
  final DateTime alarmTime;

  ReminderItem({
    required super.id,
    required super.createdAt,
    required this.text,
    required this.alarmTime,
  }) : super(type: ItemType.reminder);

  @override
  Map<String, dynamic> toDataJson() {
    return {
      'id': id,
      'text': text,
      'alarm_time': alarmTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'type': type.name,
    };
  }
}