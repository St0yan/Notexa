import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
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

enum SortMode {
    dateAsc,
    dateDesc
  }

class HomeController {

  HomeController._private();

  static final HomeController instance = HomeController._private();

  late Function onUpdate;
  final supabaseService = SupabaseService();

  HomeController({required this.onUpdate});

  SortMode sortMode = SortMode.dateAsc;

  final List<BaseItem> items = [];
  final List<BaseItem> offlineQueue = [];

  bool isSyncing = false;

  late Box<String> box;
  late Box settingsBox;

  Future<void> init() async {
    await ensureHiveIsValid();

    box = await Hive.openBox<String>('items');
    settingsBox = await Hive.openBox('settings');

    final savedMode = settingsBox.get('sortMode');
    if (savedMode != null) {
      sortMode = SortMode.values[savedMode];
    }

    items.clear();
    for (final jsonString in box.values) {
      try {
        final json = jsonDecode(jsonString);
        final item = supabaseService.decodeItem(json);
        items.add(item);
      } catch (_) {}
    }

    isSyncing = true;
    onUpdate();

    final hasInternet = await _checkInternet();
    if (!hasInternet) {
      isSyncing = false;
      onUpdate();
      return;
    }

    await _loadFromSupabase();
    _supabaseRealtime();
    _retrySync();
  }

  List<BaseItem> decodeHiveItems(List<String> values) {
    final result = <BaseItem>[];
    final service = SupabaseService();

    for (final jsonString in values) {
      try {
        final json = jsonDecode(jsonString);
        final item = service.decodeItem(json);
        result.add(item);
      } catch (_) {}
    }

    return result;
  }

  Future<void> ensureHiveIsValid() async {
    final box = await Hive.openBox<String>('items');

    bool invalidFound = false;

    for (final value in box.values) {
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
      await box.clear();
    }
  }

  Future<void> _loadFromSupabase() async {
    isSyncing = true;
    onUpdate();

    try {
      final data = await Supabase.instance.client
          .from('items')
          .select();

      items.clear();
      await box.clear();

      for (final row in data) {
        final item = supabaseService.decodeItem(row);
        items.add(item);
        box.put(item.id, jsonEncode(row));
      }

    } catch (e) {
      items.clear();

      for (final jsonString in box.values) {
        try {
          final json = jsonDecode(jsonString);
          final item = supabaseService.decodeItem(json);
          items.add(item);
        } catch (_) {}
      }
    }

    isSyncing = false;
    sortItems();
  }

  void _supabaseRealtime() {
    final channel = Supabase.instance.client.channel('items_channel');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'items',
      callback: (payload) async {
        if(!isSyncing) {
          await _loadFromSupabase();
        }
      },
    );

    channel.subscribe();
  }

  Future<void> _retrySync() async {
    final hasInternet = await _checkInternet();
      if (!hasInternet) {
        isSyncing = false;
        onUpdate();
        return;
      }

    if (offlineQueue.isEmpty) {
      isSyncing = false;
      onUpdate();
      return;
    }

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

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty;
    } catch (_) {
      return false;
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
      sortItems();
      box.delete(item.id);

      if (item is ReminderItem) {
        NotificationService.cancelReminder(item.id);
      }

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
        ).then((result) {
          if (result != null && result is BaseItem) {
            updateItem(result);
          }
        });
        break;

      case ItemType.reminder:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddReminderPage(editItem: item as ReminderItem)),
        ).then((result) {
          if (result != null && result is BaseItem) {
            updateItem(result);
          }
        });
        break;

      case ItemType.note:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddNotePage(editItem: item as NoteItem)),
        ).then((result) {
          if (result != null && result is BaseItem) {
            updateItem(result);
          }
        });
        break;

      case ItemType.task:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddTaskPage(editItem: item as TaskItem)),
        ).then((result) {
          if (result != null && result is BaseItem) {
            updateItem(result);
          }
        });
        break;

      case ItemType.goal:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddGoalPage(editItem: item as GoalItem)),
        ).then((result) {
          if (result != null && result is BaseItem) {
            updateItem(result);
          }
        });
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
      box.put(item.id, jsonEncode(item.toJson()));
      await supabaseService.uploadItem(item);

      if (item is ReminderItem) {
        NotificationService.scheduleReminder(
          id: item.id,
          text: item.text,
          dateTime: item.alarmTime,
        );
      }

      onUpdate();
    } catch (_) {
      offlineQueue.add(item);
      _retrySync();
    }
    sortItems();
  }

  void updateItem(BaseItem updated) async {
    try {
      final index = items.indexWhere((i) => i.id == updated.id);
      if (index != -1) {
        items[index] = updated;
      }

      box.put(updated.id, jsonEncode(updated.toJson()));
      await supabaseService.uploadOrUpdateItem(updated);

      if (updated is ReminderItem) {
        NotificationService.cancelReminder(updated.id);
        NotificationService.scheduleReminder(
          id: updated.id,
          text: updated.text,
          dateTime: updated.alarmTime,
        );
      }

      onUpdate();
    } catch (_) {
      offlineQueue.add(updated);
      _retrySync();
    }
    sortItems();
  }

  void sortItems() {
    items.sort((a, b) {
      DateTime dateA;
      DateTime dateB;

      if (a is ReminderItem) {
        dateA = a.alarmTime;
      } else {
        dateA = a.createdAt;
      }

      if (b is ReminderItem) {
        dateB = b.alarmTime;
      } else {
        dateB = b.createdAt;
      }

      if (sortMode == SortMode.dateAsc) {
        return dateA.compareTo(dateB);
      } else {
        return dateB.compareTo(dateA);
      }
    });
  }

  void deleteItemById(String id) {
    BaseItem? item;

    for (final i in items) {
      if (i.id == id) {
        item = i;
        break;
      }
    }

    if (item != null) {
      deleteItem(item);
    }
  }

  void updateReminderTime(String id, DateTime newTime) {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.id == id && item is ReminderItem) {
        final updated = ReminderItem(
          id: item.id,
          createdAt: item.createdAt,
          text: item.text,
          alarmTime: newTime,
        );

        items[i] = updated;

        sortItems();

        box.put(item.id, jsonEncode(updated.toJson()));
        supabaseService.uploadOrUpdateItem(updated);

        onUpdate();
        break;
      }
    }
  }
}