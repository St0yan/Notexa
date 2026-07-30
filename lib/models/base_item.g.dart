// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
