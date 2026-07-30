// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdeaItemAdapter extends TypeAdapter<IdeaItem> {
  @override
  final int typeId = 4;

  @override
  IdeaItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdeaItem(
      id: fields[0] as String,
      createdAt: fields[2] as DateTime,
      text: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IdeaItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(3)
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
      other is IdeaItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
