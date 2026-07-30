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
      id: fields[0] as String,
      createdAt: fields[2] as DateTime,
      text: fields[3] as String,
      alarmTime: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.alarmTime)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.createdAt);
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
