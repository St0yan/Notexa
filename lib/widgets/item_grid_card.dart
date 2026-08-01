import 'package:flutter/material.dart';
import '../models/base_item.dart';
import 'item_type_helpers.dart';

class ItemGridCard extends StatelessWidget {
  final BaseItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ItemGridCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: getColorForType(item.type),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              getIconForType(item.type),
              size: 22,
              color: Colors.black87,
            ),

            const SizedBox(height: 6),

            Text(
              getTitleForItem(item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              getPreviewText(item),
              maxLines: 6,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}