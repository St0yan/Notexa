import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'home_controller.dart';
import '../services/permission_dialogs.dart';
import '../models/base_item.dart';
import '../widgets/item_grid_card.dart';
import 'menu_controller.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final HomeController controller;
  const HomePage({super.key, required this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey menuButtonKey = GlobalKey();
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showNotificationPermissionDialog(context);
      await showExactAlarmDialog(context);
    });

    widget.controller.onItemsChanged = () {
      setState(() {});
    };

    searchCtrl.addListener(() {
      setState(() {});
    });
  }

  void _showTypeMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _typeButton(context,
                icon: Icons.note_alt,
                color: Colors.yellow.shade600,
                text: "Бележка",
                type: ItemType.note,
              ),
              _typeButton(context,
                icon: Icons.checklist,
                color: Colors.blue.shade600,
                text: "Задача",
                type: ItemType.task,
              ),
              _typeButton(context,
                icon: Icons.lightbulb,
                color: Colors.orange.shade600,
                text: "Идея",
                type: ItemType.idea,
              ),
              _typeButton(context,
                icon: Icons.alarm,
                color: Colors.red.shade600,
                text: "Напомняне",
                type: ItemType.reminder,
              ),
              _typeButton(context,
                icon: Icons.flag,
                color: Colors.green.shade600,
                text: "Цел",
                type: ItemType.goal,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _typeButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
    required ItemType type,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      onTap: () {
        Navigator.pop(context);
        widget.controller.createNewItem(context, type);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeIndex = widget.controller.settingsBox.get('fontSize', defaultValue: 1);

    double fontSize;
    switch (fontSizeIndex) {
      case 0: fontSize = 14; break;
      case 1: fontSize = 16; break;
      case 2: fontSize = 18; break;
      default: fontSize = 16;
    }

    List<BaseItem> visibleItems = widget.controller.currentFilter == null
        ? widget.controller.items
        : widget.controller.items.where((i) => i.type == widget.controller.currentFilter).toList();
    
    if (widget.controller.currentFilter != null) {
      visibleItems = visibleItems
          .where((i) => i.type == widget.controller.currentFilter)
          .toList();
    }

    if (searchCtrl.text.isNotEmpty) {
      final query = searchCtrl.text.toLowerCase();
      visibleItems = visibleItems.where((item) => item.title.toLowerCase().contains(query)).toList();
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: 'Търси...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                suffixIcon: searchCtrl.text.isEmpty
                    ? const Icon(Icons.search)
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchCtrl.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            key: menuButtonKey,
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    controller: controller,
                  ),
                ),
              );
            },
          ),
          widget.controller.isSyncing
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
      body: MasonryGridView.count(
        key: ValueKey(searchCtrl.text),
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.all(8),
        itemCount: visibleItems.length,
        itemBuilder: (context, index) {
          final item = visibleItems[index];
          return ItemGridCard(
            item: item,
            fontSize: fontSize,
            onTap: () => widget.controller.openItem(context, item),
            onDelete: () {
              widget.controller.deleteItem(item);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Елементът е изтрит!'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  margin: EdgeInsets.all(12),
                ),
              );
            },
            onEdit: () => widget.controller.openItem(context, item),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTypeMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}