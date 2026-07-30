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
      text: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IdeaItem obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.text);
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
