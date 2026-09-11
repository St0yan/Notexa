import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/base_item.dart';
import '../models/note_item.dart';
import '../models/task_item.dart';
import '../models/idea_item.dart';
import '../models/reminder_item.dart';
import '../models/goal_item.dart';
import '../models/deleted_item_marker.dart';

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
    // --- ID ---
    final id = json['id']?.toString() ?? "";

    // --- TYPE (safe) ---
    final rawType = json['type']?.toString() ?? "";
    ItemType? type;

    try {
      type = ItemType.values.firstWhere((t) => t.name == rawType);
    } catch (_) {
      // Ако типът е "deleted" или невалиден → връщаме DeletedItemMarker
      return DeletedItemMarker(id);
    }

    // --- CREATED AT (safe) ---
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'].toString());
    } catch (_) {
      createdAt = DateTime.now();
    }

    // --- DATA (safe) ---
    Map<String, dynamic> data = {};

    try {
      final rawData = json['data'];

      if (rawData == null) {
        data = {};
      } else if (rawData is Map) {
        data = Map<String, dynamic>.from(rawData);
      } else if (rawData is String) {
        data = decodeData(rawData);
      } else {
        data = {};
      }
    } catch (_) {
      data = {};
    }

    // --- ENTRIES (safe) ---
    List<Map<String, dynamic>> safeEntries = [];
    if (data['entries'] != null) {
      try {
        dynamic rawEntries = data['entries'];

        if (rawEntries is String) {
          rawEntries = jsonDecode(rawEntries);
        }

        if (rawEntries is List) {
          safeEntries = rawEntries.map((e) {
            if (e is Map) {
              return Map<String, dynamic>.from(e);
            }
            return <String, dynamic>{};
          }).toList();
        }
      } catch (_) {
        safeEntries = [];
      }
    }

    // --- ALARM TIME (safe) ---
    DateTime alarmTime = DateTime.now();
    if (data['alarm_time'] != null) {
      try {
        alarmTime = DateTime.parse(data['alarm_time'].toString());
      } catch (_) {}
    }

    // --- SWITCH ---
    switch (type) {
      case ItemType.note:
        return NoteItem(
          id: id,
          createdAt: createdAt,
          title: data['title']?.toString() ?? "",
          text: data['text']?.toString() ?? "",
        );

      case ItemType.task:
        final entries = safeEntries.map((e) {
          return TaskEntry(
            text: e['text']?.toString() ?? "",
            isDone: e['isDone'] == true,
          );
        }).toList();

        return TaskItem(
          id: id,
          createdAt: createdAt,
          title: data['title']?.toString() ?? "",
          entries: entries,
        );

      case ItemType.idea:
        return IdeaItem(
          id: id,
          createdAt: createdAt,
          text: data['text']?.toString() ?? "",
        );

      case ItemType.reminder:
        return ReminderItem(
          id: id,
          createdAt: createdAt,
          text: data['text']?.toString() ?? "",
          alarmTime: alarmTime,
        );

      case ItemType.goal:
        return GoalItem(
          id: id,
          createdAt: createdAt,
          title: data['title']?.toString() ?? "",
          text: data['text']?.toString() ?? "",
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

  Future<bool> exists(String id) async {
    try {
      final result = await Supabase.instance.client
          .from('items')
          .select()
          .eq('id', id);

      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}