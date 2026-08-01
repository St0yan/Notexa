import 'package:flutter/material.dart';
import '../models/base_item.dart';
import '../widgets/item_type_helpers.dart';

class ItemCard extends StatelessWidget {
  final BaseItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: getColorForType(item.type),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          getIconForType(item.type),
          size: 28,
          color: Colors.black87,
        ),
        title: Text(
          getTitleForItem(item),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: getSubtitleForItem(item),
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
