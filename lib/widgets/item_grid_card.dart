import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/base_item.dart';
import '../models/task_item.dart';
import 'item_type_helpers.dart';

class ItemGridCard extends StatelessWidget {
  final BaseItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ItemGridCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isTask = item.type == ItemType.task;
    final task = isTask ? item as TaskItem : null;
    return InkWell(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact(); // 🔥 iOS-style вибрация

        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset pos = box.localToGlobal(Offset.zero);

        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "",
          transitionDuration: const Duration(milliseconds: 180),
          pageBuilder: (_, __, ___) {
            return Stack(
              children: [
                // 🔥 Blur background (Frosted Glass)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(color: Colors.black.withOpacity(0.1)),
                  ),
                ),

                // 🔥 Bubble menu with animation
                Positioned(
                  left: pos.dx + box.size.width - 160,
                  top: pos.dy - 10,
                  child: _BubbleMenu(
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                ),
              ],
            );
          },
          transitionBuilder: (_, anim, __, child) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
              ),
              child: FadeTransition(
                opacity: anim,
                child: child,
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
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
            if (isTask) ...[
              const SizedBox(height: 6),

              for (int i = 0; i < task!.entries.length; i++)
                Row(
                  children: [
                    Icon(
                      task.entries[i].isDone
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: task.entries[i].isDone
                          ? Colors.green
                          : Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task.entries[i].text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          decoration: task.entries[i].isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.entries[i].isDone
                              ? Colors.black54
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
            ]
            else
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

class _BubbleMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BubbleMenu({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BubbleItem(
              icon: Icons.edit,
              color: Colors.blue,
              text: "Редактирай",
              onTap: () {
                Navigator.pop(context);
                Future.microtask(onEdit);
              },
            ),
            _BubbleItem(
              icon: Icons.delete,
              color: Colors.red,
              text: "Изтрий",
              onTap: () {
                Navigator.pop(context);
                Future.microtask(onDelete);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BubbleItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onTap;

  const _BubbleItem({
    required this.icon,
    required this.color,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}