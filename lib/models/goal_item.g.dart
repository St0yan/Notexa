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
      title: fields[0] as String,
      text: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GoalItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.text);
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
