import 'package:flutter/material.dart';
import '../models/base_item.dart';
import '../models/note_item.dart';
import '../models/goal_item.dart';
import '../models/idea_item.dart';
import '../models/reminder_item.dart';
import '../models/task_item.dart';

IconData getIconForType(ItemType type) {
  switch (type) {
    case ItemType.note:
      return Icons.note_alt;
    case ItemType.task:
      return Icons.checklist;
    case ItemType.idea:
      return Icons.lightbulb;
    case ItemType.reminder:
      return Icons.alarm;
    case ItemType.goal:
      return Icons.flag;
  }
}

Color getColorForType(ItemType type) {
  switch (type) {
    case ItemType.note:
      return Colors.yellow.shade100;
    case ItemType.task:
      return Colors.blue.shade100;
    case ItemType.idea:
      return Colors.orange.shade100;
    case ItemType.reminder:
      return Colors.red.shade100;
    case ItemType.goal:
      return Colors.green.shade100;
  }
}

String getTitleForItem(BaseItem item) {
  if (item is NoteItem) return item.title;
  if (item is TaskItem) return item.title;
  if (item is IdeaItem) return item.text;
  if (item is ReminderItem) return item.text;
  if (item is GoalItem) return item.title;
  return "";
}

Widget? getSubtitleForItem(BaseItem item) {
  if (item is TaskItem) {
    return Text("${item.entries.length} задачи");
  }
  return null;
}

String getPreviewText(BaseItem item) {
  if (item is NoteItem) return item.text;
  if (item is IdeaItem) return item.text;
  if (item is ReminderItem) return item.text;
  if (item is GoalItem) return item.text;

  if (item is TaskItem) {
    return item.entries
        .map((e) => "- ${e.text}")
        .take(4)
        .join("\n");
  }

  return "";
}