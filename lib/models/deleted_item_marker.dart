import 'package:hive/hive.dart';
import 'base_item.dart';

part 'deleted_item_marker.g.dart';

@HiveType(typeId: 99) // избери свободен typeId
class DeletedItemMarker extends BaseItem {
  DeletedItemMarker(String id)
      : super(
          id: id,
          createdAt: DateTime.now(),
          type: ItemType.note, // няма значение, не се използва
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_deleted': true,
    };
  }
}