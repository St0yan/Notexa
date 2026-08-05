import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notexa/services/supabase_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'home_controller.dart';
import '../models/base_item.dart';
import '../widgets/item_grid_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController controller;
  final supabaseService = SupabaseService();
  final List<BaseItem> items = [];
  late Box<String> box;

  @override
  void initState() {
    super.initState();
    controller = HomeController(onUpdate: () => setState(() {}));
    controller.init();
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
              _typeButton(
                context,
                icon: Icons.note_alt,
                color: Colors.yellow.shade600,
                text: "Бележка",
                type: ItemType.note,
              ),
              _typeButton(
                context,
                icon: Icons.checklist,
                color: Colors.blue.shade600,
                text: "Задача",
                type: ItemType.task,
              ),
              _typeButton(
                context,
                icon: Icons.lightbulb,
                color: Colors.orange.shade600,
                text: "Идея",
                type: ItemType.idea,
              ),
              _typeButton(
                context,
                icon: Icons.alarm,
                color: Colors.red.shade600,
                text: "Напомняне",
                type: ItemType.reminder,
              ),
              _typeButton(
                context,
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
      title: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      onTap: () {
        Navigator.pop(context);
        controller.createNewItem(context, type);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.search, size: 26),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 26),
            onPressed: () {},
          ),
          controller.isSyncing
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
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.all(8),
        itemCount: controller.items.length,
        itemBuilder: (context, index) {
          final item = controller.items[index];
          return ItemGridCard(
            item: item,
            onTap: () => controller.openItem(context, item),
            onDelete: () {
              controller.deleteItem(item);
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
            onEdit: () => controller.openItem(context, item),
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