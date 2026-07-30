// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalItemAdapter extends TypeAdapter<GoalItem> {
  @override
  final int typeId = 6;

  @override
  GoalItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalItem(
      id: fields[0] as String,
      createdAt: fields[2] as DateTime,
      title: fields[3] as String,
      text: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GoalItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.text)
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
      other is GoalItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
