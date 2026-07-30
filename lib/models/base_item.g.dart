// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BaseItemAdapter extends TypeAdapter<BaseItem> {
  @override
  final int typeId = 100;

  @override
  BaseItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BaseItem(
      id: fields[0] as String,
      type: fields[1] as ItemType,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BaseItem obj) {
    writer
      ..writeByte(3)
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
      other is BaseItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemTypeAdapter extends TypeAdapter<ItemType> {
  @override
  final int typeId = 0;

  @override
  ItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemType.note;
      case 1:
        return ItemType.task;
      case 2:
        return ItemType.idea;
      case 3:
        return ItemType.reminder;
      case 4:
        return ItemType.goal;
      default:
        return ItemType.note;
    }
  }

  @override
  void write(BinaryWriter writer, ItemType obj) {
    switch (obj) {
      case ItemType.note:
        writer.writeByte(0);
        break;
      case ItemType.task:
        writer.writeByte(1);
        break;
      case ItemType.idea:
        writer.writeByte(2);
        break;
      case ItemType.reminder:
        writer.writeByte(3);
        break;
      case ItemType.goal:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
