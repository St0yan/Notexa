import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/base_item.dart';
import '../models/note_item.dart';
import '../models/task_item.dart';
import '../models/idea_item.dart';
import '../models/reminder_item.dart';
import '../models/goal_item.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<void> uploadItem(BaseItem item) async {
    await supabase.from('items').insert(item.toJson());
  }

  // --- ДЕКОДИРАНЕ НА DATA ---
  Map<String, dynamic> decodeData(dynamic raw) {
    if (raw == null) return {};

    // Ако е Map → директно
    if (raw is Map) return Map<String, dynamic>.from(raw);

    // Ако е String → опитваме да декодираме
    if (raw is String) {
      try {
        dynamic decoded = jsonDecode(raw);

        // Ако е Map → готово
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }

        // Ако е String → опитваме втори път
        if (decoded is String) {
          decoded = jsonDecode(decoded);
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          }
        }
      } catch (_) {}
    }

    return {};
  }

  BaseItem decodeItem(Map<dynamic, dynamic> json) {
    final type = ItemType.values.firstWhere((t) => t.name == json['type']);
    final id = json['id'] ?? "";
    final createdAt = DateTime.tryParse(json['created_at'] ?? "") ?? DateTime.now();

    Map<String, dynamic> normalize(Map<dynamic, dynamic> input) {
      return input.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), normalize(value));
        }
        return MapEntry(key.toString(), value);
      });
    }

    Map<String, dynamic> data = {};

    if (json['data'] != null) {
      if (json['data'] is String) {
        data = decodeData(json['data']);   // <-- поправено
      } else if (json['data'] is Map<String, dynamic>) {
        data = Map<String, dynamic>.from(json['data']);
      }
    } else {
      data = normalize(json);
    }

    switch (type) {
      case ItemType.note:
        return NoteItem(
          id: id,
          createdAt: createdAt,
          title: data['title'] ?? "",
          text: data['text'] ?? "",
        );

      case ItemType.task:
        dynamic rawEntries = data['entries'];

        if (rawEntries is String) {
          rawEntries = jsonDecode(rawEntries);
        }
        rawEntries ??= [];

        final entriesJson = rawEntries as List? ?? [];

        final entries = entriesJson.map((e) {
          return TaskEntry(
            text: e['text'] ?? "",
            isDone: e['isDone'] ?? false,
          );
        }).toList();

        return TaskItem(
          id: id,
          createdAt: createdAt,
          title: data['title'] ?? "",
          entries: entries,
        );

      case ItemType.idea:
        return IdeaItem(
          id: id,
          createdAt: createdAt,
          text: data['text'] ?? "",
        );

      case ItemType.reminder:
        return ReminderItem(
          id: id,
          createdAt: createdAt,
          text: data['text'] ?? "",
          alarmTime: DateTime.tryParse(data['alarm_time'] ?? "") ?? DateTime.now(),
        );

      case ItemType.goal:
        return GoalItem(
          id: id,
          createdAt: createdAt,
          title: data['title'] ?? "",
          text: data['text'] ?? "",
        );
    }
  }

  Future<void> updateItem(BaseItem item) async {
    await supabase.from('items').update(item.toJson()).eq('id', item.id);
  }

  Future<void> deleteItem(String id) async {
    await supabase.from('items').delete().eq('id', id);
  }

  Future<void> uploadOrUpdateItem(BaseItem item) async {
    final existing = await supabase
        .from('items')
        .select()
        .eq('id', item.id)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('items').insert(item.toJson());
    } else {
      await supabase.from('items').update(item.toJson()).eq('id', item.id);
    }
  }
}