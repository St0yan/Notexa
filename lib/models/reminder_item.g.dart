// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderItemAdapter extends TypeAdapter<ReminderItem> {
  @override
  final int typeId = 5;

  @override
  ReminderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderItem(
      text: fields[0] as String,
      alarmTime: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.alarmTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
