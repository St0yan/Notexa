import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/base_item.dart';
import '../models/note_item.dart';
import '../models/task_item.dart';
import '../models/idea_item.dart';
import '../models/reminder_item.dart';
import '../models/goal_item.dart';
import '../models/deleted_item_marker.dart';
import 'add_goal_page.dart';
import 'add_idea_page.dart';
import 'add_note_page.dart';
import 'add_reminder_page.dart';
import 'add_task_page.dart';


class HomeController {
  final Function onUpdate;
  final supabaseService = SupabaseService();

  HomeController({required this.onUpdate});

  final List<BaseItem> items = [];
  final List<BaseItem> offlineQueue = [];

  bool isSyncing = false;

  late Box<String> box;

  Future<void> init() async {
    await ensureHiveIsValid();   // <-- добавяме това

    box = await Hive.openBox<String>('items');

    final all = box.values.toList();

    items.clear();

    for (final jsonString in all) {
      try {
        final json = jsonDecode(jsonString);
        final item = supabaseService.decodeItem(json);
        items.add(item);
      } catch (_) {}
    }

    _loadFromSupabase();
    _supabaseRealtime();
    _retrySync();
  }

  Future<void> ensureHiveIsValid() async {
    final box = await Hive.openBox<String>('items');

    bool invalidFound = false;

    for (final value in box.values) {
      if (value is! String) {
        invalidFound = true;
        break;
      }

      // Проверка дали String е валиден JSON
      try {
        final decoded = jsonDecode(value);
        if (decoded is! Map) {
          invalidFound = true;
          break;
        }
      } catch (_) {
        invalidFound = true;
        break;
      }
    }

    if (invalidFound) {
      print("⚠ Hive съдържа невалидни записи → изчиствам box-а...");
      await box.clear();
    }
  }

  Future<void> _loadFromSupabase() async {
    isSyncing = true;
    onUpdate();

    final data = await Supabase.instance.client
        .from('items')
        .select();

    items.clear();
    await box.clear();

    for (final row in data) {
      try {
        final json = row;
        final item = supabaseService.decodeItem(json);
        items.add(item);
        box.put(item.id, jsonEncode(json));
      } catch (e) {
        print("Decode error: $e");
      }
    }

    isSyncing = false;
    onUpdate();
  }

  void _supabaseRealtime() {
    final channel = Supabase.instance.client.channel('items_channel');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'items',
      callback: (payload) {
        _loadFromSupabase();
      },
    );

    channel.subscribe();
  }

  Future<void> _retrySync() async {
    if (offlineQueue.isEmpty) return;

    isSyncing = true;
    onUpdate();

    final List<BaseItem> stillPending = [];

    for (final item in offlineQueue) {
      try {
        if (item is DeletedItemMarker) {
          await supabaseService.deleteItem(item.id);
        } else {
          await supabaseService.uploadOrUpdateItem(item);
        }
      } catch (_) {
        stillPending.add(item);
      }
    }

    offlineQueue
      ..clear()
      ..addAll(stillPending);

    isSyncing = false;
    onUpdate();

    if (offlineQueue.isNotEmpty) {
      Future.delayed(const Duration(seconds: 5), _retrySync);
    }
  }

  Future<void> uploadItem(BaseItem item) async {
    await Supabase.instance.client
        .from('items')
        .insert(item.toJson());
  }

  void deleteItem(BaseItem item) async {
    try {
      await supabaseService.deleteItem(item.id);
      items.remove(item);
      box.delete(item.id);
      onUpdate();
    } catch (_) {
      offlineQueue.add(DeletedItemMarker(item.id));
      _retrySync();
    }
  }

  void openItem(BuildContext context, BaseItem item) {
    switch (item.type) {
      case ItemType.idea:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddIdeaPage(editItem: item as IdeaItem)),
        );
        break;

      case ItemType.reminder:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddReminderPage(editItem: item as ReminderItem)),
        );
        break;

      case ItemType.note:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddNotePage(editItem: item as NoteItem)),
        );
        break;

      case ItemType.task:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddTaskPage(editItem: item as TaskItem)),
        );
        break;

      case ItemType.goal:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddGoalPage(editItem: item as GoalItem)),
        );
        break;
    }
  }

  void createNewItem(BuildContext context, ItemType type) {
    switch (type) {
      case ItemType.note:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddNotePage())
        ).then((result) {
          if (result != null && result is NoteItem) {
            addNewItem(result);
          }
        });
        break;

      case ItemType.task:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskPage())
        ).then((result) {
          if (result != null && result is TaskItem) {
            addNewItem(result);
          }
        });
        break;

      case ItemType.idea:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddIdeaPage())
        ).then((result) {
          if (result != null && result is IdeaItem) {
            addNewItem(result);
          }
        });
        break;

      case ItemType.reminder:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddReminderPage())
        ).then((result) {
          if (result != null && result is ReminderItem) {
            addNewItem(result);
          }
        });
        break;

      case ItemType.goal:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddGoalPage())
        ).then((result) {
          if (result != null && result is GoalItem) {
            addNewItem(result);
          }
        });
        break;
    }
  }

  void addNewItem(BaseItem item) async {
    try {
      final json = item.toJson();

      items.add(item);
      box.put(item.id, jsonEncode(jsonEncode(item.toJson())));
      await supabaseService.uploadItem(item);
      onUpdate();
    } catch (_) {
      offlineQueue.add(item);
      _retrySync();
    }
  }
}