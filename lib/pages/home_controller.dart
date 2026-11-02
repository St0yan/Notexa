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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:local_auth/local_auth.dart';

enum SortMode {
  dateAsc,
  dateDesc
}

class HomeController {

  static late HomeController instance;
  final supabaseService = SupabaseService();

  HomeController() { instance = this; }

  SortMode sortMode = SortMode.dateAsc;

  final List<BaseItem> items = [];

  bool isSyncing = false;
  bool lockEnabled = true;

  int lockTimeoutSeconds = 60;

  late Box<String> box;
  late Box settingsBox;
  late Box<String> offlineBox;

  final LocalAuthentication _auth = LocalAuthentication();

  VoidCallback? onItemsChanged;
  late VoidCallback onThemeChanged;

  ThemeMode get currentTheme {
    final index = settingsBox.get('themeMode', defaultValue: ThemeMode.system.index);
    return ThemeMode.values[index];
  }

  Future<void> init() async {
    await ensureHiveIsValid();

    box = await Hive.openBox<String>('items');
    settingsBox = await Hive.openBox('settings');
    offlineBox = await Hive.openBox<String>('offline_queue');
    lockEnabled = settingsBox.get('lockEnabled', defaultValue: true);
    lockTimeoutSeconds =
    settingsBox.get(
      'lockTimeoutSeconds',
      defaultValue: 0,
    );

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

    sortItems();
    onItemsChanged?.call();

    final hasInternet = await _checkInternet();
    if (hasInternet) {
      await _loadFromSupabase();
      _supabaseRealtime();
      _retrySync();
    }

    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        _retrySync();
      }
    });
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
    onItemsChanged?.call();

    List<dynamic> remoteItems = [];

    // --- 1) Опит за зареждане от Supabase ---
    try {
      remoteItems = await Supabase.instance.client
          .from('items')
          .select();
    } catch (_) {
      // Няма интернет → използваме локалните данни
      isSyncing = false;
      sortItems();
      return;
    }

    // --- 2) Merge map ---
    final Map<String, BaseItem> merged = {};

    // --- 3) Локални items ---
    for (final jsonString in box.values) {
      try {
        final json = jsonDecode(jsonString);

        // Ако локално е deleted → игнорирай
        if (json['type'] == 'deleted') continue;

        final item = supabaseService.decodeItem(json);
        merged[item.id] = item;
      } catch (_) {
        // Ако локалният JSON е повреден → игнорирай
        continue;
      }
    }

    // --- 4) Remote items ---
    for (final row in remoteItems) {
      try {
        // Ако локално е deleted → remote не трябва да overwrite-ва
        if (box.containsKey(row['id'])) {
          final localJson = jsonDecode(box.get(row['id'])!);
          if (localJson['type'] == 'deleted') {
            continue;
          }
        }

        final item = supabaseService.decodeItem(row);

        // Ако remote е DeletedItemMarker → игнорирай
        if (item is DeletedItemMarker) continue;

        // Добави/overwrite remote item
        merged[item.id] = item;

        // 🔥 Записваме item.toJson(), НЕ Supabase JSON
        box.put(item.id, jsonEncode(item.toJson()));
      } catch (_) {
        // Ако remote JSON е повреден → игнорирай
        continue;
      }
    }

    // --- 5) Обновяване на списъка ---
    items
      ..clear()
      ..addAll(merged.values);

    isSyncing = false;
    sortItems();
    onItemsChanged?.call();
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
    if (!hasInternet) return;

    if (offlineBox.isEmpty) return;

    isSyncing = true;
    onItemsChanged?.call();

    final List<String> stillPending = [];

    for (final jsonString in offlineBox.values) {
      try {
        final json = jsonDecode(jsonString);

        // 🔥 Безопасно декодиране
        final item = supabaseService.decodeItem(json);

        // 🔥 Ако е DeletedItemMarker → изтриваме remote
        if (item is DeletedItemMarker) {
          try {
            await supabaseService.deleteItem(item.id);
          } catch (_) {
            // remote delete неуспешно → оставяме за следващ retry
            stillPending.add(jsonString);
          }
          continue;
        }

        // 🔥 Проверка дали remote item съществува
        bool existsRemote = false;
        try {
          existsRemote = await supabaseService.exists(item.id);
        } catch (_) {
          // ако Supabase хвърли грешка → оставяме за следващ retry
          stillPending.add(jsonString);
          continue;
        }

        // 🔥 Upload или Update
        try {
          if (!existsRemote) {
            await supabaseService.uploadItem(item);
          } else {
            await supabaseService.uploadOrUpdateItem(item);
          }
        } catch (_) {
          // неуспешен upload/update → оставяме за следващ retry
          stillPending.add(jsonString);
        }

      } catch (_) {
        // JSON повреден → оставяме го за следващ retry
        stillPending.add(jsonString);
      }
    }

    // 🔥 Изчистваме offlineBox
    await offlineBox.clear();

    // 🔥 Връщаме само тези, които не успяха
    for (final pending in stillPending) {
      offlineBox.add(pending);
    }

    isSyncing = false;
    onItemsChanged?.call();

    // 🔥 Ако има още pending → опитваме пак след 5 секунди
    if (offlineBox.isNotEmpty) {
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
    try {
      await Supabase.instance.client
        .from('items')
        .insert(item.toJson());
    } catch (e) {
      print("Supabase upload error: $e");
    }
  }

  void deleteItem(BaseItem item) async {
    try {
      await supabaseService.deleteItem(item.id);

      items.remove(item);
      box.delete(item.id);

      if (item is ReminderItem) {
        NotificationService.cancelReminder(item.id);
      }

      sortItems();
      onItemsChanged?.call();

    } catch (_) {
      final marker = DeletedItemMarker(item.id);

      offlineBox.add(jsonEncode(marker.toJson()));
      box.put(item.id, jsonEncode(marker.toJson()));

      _retrySync();
    }
  }

  void openItem(BuildContext context, BaseItem item) async {
    if (item is DeletedItemMarker) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Този елемент е маркиран за изтриване."),
        ),
      );
      return;
    }
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

      sortItems();
      onItemsChanged?.call();

    } catch (_) {
      offlineBox.add(jsonEncode(item.toJson()));
      _retrySync();
    }
  }

  void updateItem(BaseItem updated) async {
    try {
      final index = items.indexWhere((i) => i.id == updated.id);
      if (index != -1) items[index] = updated;

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

      sortItems();
      onItemsChanged?.call();

    } catch (_) {
      offlineBox.add(jsonEncode(updated.toJson()));
      _retrySync();
    }
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
        try {
          supabaseService.uploadOrUpdateItem(updated);
        } catch (_) {
          offlineBox.add(jsonEncode(updated.toJson()));
        }

        onItemsChanged?.call();
        break;
      }
    }
  }

  void setTheme(ThemeMode mode) {
    settingsBox.put('themeMode', mode.index);
    onThemeChanged();
    }

  void sortByDate() {
    if (sortMode == SortMode.dateAsc) {
      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    onItemsChanged?.call();
    }

  void sortByType() {
    items.sort((a, b) => a.type.index.compareTo(b.type.index));
    onItemsChanged?.call();
    }

  void sortAlphabetically() {
    items.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    onItemsChanged?.call();
    }

  ItemType? currentFilter;

  void filterBy(ItemType? type) {
    currentFilter = type;
    onItemsChanged?.call();
  }

  void setFontSize(int sizeIndex) {
    settingsBox.put('fontSize', sizeIndex);
    onItemsChanged?.call();
  }

  Future<bool> authenticateUser() async {
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason:
            'Моля, потвърдете самоличността си, за да отворите този елемент.',
        biometricOnly: true,
        persistAcrossBackgrounding: false,
      );
      return didAuthenticate;
    } catch (e) {
      print('❌ AUTH ERROR: $e');
      return false;
    }
  }

  Future<void> setLockEnabled(bool value) async {
    lockEnabled = value;

    final settingsBox =
        await Hive.openBox('settings');

    await settingsBox.put(
      'lockEnabled',
      value,
    );

    onItemsChanged?.call();
  }

  Future<void> setLockTimeout(
    int seconds,
  ) async {
    lockTimeoutSeconds = seconds;

    final settingsBox =
        await Hive.openBox('settings');

    await settingsBox.put(
      'lockTimeoutSeconds',
      seconds,
    );

    onThemeChanged?.call();
  }
}