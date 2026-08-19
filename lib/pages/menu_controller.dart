import 'package:flutter/material.dart';
import 'home_controller.dart';
import '../models/base_item.dart';

final controller = HomeController.instance;

void showMainMenu(BuildContext context, GlobalKey key) {
  final RenderBox button = key.currentContext!.findRenderObject() as RenderBox;
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  final position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );

  showMenu<String>(
    context: context,
    position: position,
    items: [
      PopupMenuItem(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Настройки"),
            Icon(Icons.arrow_right),
          ],
        ),
        onTap: () {
          Future.delayed(Duration.zero, () {
            showSettingsMenu(context, position);
          });
        },
      ),
      PopupMenuItem(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Категории"),
            Icon(Icons.arrow_right),
          ],
        ),
        onTap: () {
          Future.delayed(Duration.zero, () {
            showCategoriesMenu(context, position);
          });
        },
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        child: const Text("Статистика"),
        onTap: () {
          Future.delayed(Duration.zero, () {
            Navigator.pushNamed(context, "/stats");
          });
        },
      ),
      PopupMenuItem(
        child: const Text("Кошче"),
        onTap: () {
          Future.delayed(Duration.zero, () {
            Navigator.pushNamed(context, "/trash");
          });
        },
      ),
    ],
  );
}

void showSettingsMenu(BuildContext context, RelativeRect position) {
  showMenu<String>(
    context: context,
    position: position,
    items: [
      PopupMenuItem(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Тема"),
            Icon(Icons.arrow_right),
          ],
        ),
        onTap: () {
          Future.delayed(Duration.zero, () {
            showThemeMenu(context, position);
          });
        },
      ),
      PopupMenuItem(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Сортиране"),
            Icon(Icons.arrow_right),
          ],
        ),
        onTap: () {
          Future.delayed(Duration.zero, () {
            showSortMenu(context, position);
          });
        },
      ),
      PopupMenuItem(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Размер на текста"),
            Icon(Icons.arrow_right),
          ],
        ),
        onTap: () {
          Future.delayed(Duration.zero, () {
            showFontSizeMenu(context, position);
          });
        },
      ),
    ],
  );
}

void showThemeMenu(BuildContext context, RelativeRect position) {
  showMenu<String>(
    context: context,
    position: position,
    items: [
      PopupMenuItem(
        child: const Text("Светла"),
        onTap: () => controller.setTheme(ThemeMode.light),
      ),
      PopupMenuItem(
        child: const Text("Тъмна"),
        onTap: () => controller.setTheme(ThemeMode.dark),
      ),
      PopupMenuItem(
        child: const Text("Системна"),
        onTap: () => controller.setTheme(ThemeMode.system),
      ),
    ],
  );
}

void showSortMenu(BuildContext context, RelativeRect position) {
  showMenu(
    context: context,
    position: position,
    items: [
      PopupMenuItem(
        child: const Text("Дата"),
        onTap: () {
          controller.sortMode = SortMode.dateAsc;
          controller.sortByDate();
          controller.onUpdate();
        },
      ),
      PopupMenuItem(
        child: const Text("Тип"),
        onTap: () {
          controller.sortByType();
          controller.onUpdate();
        },
      ),
      PopupMenuItem(
        child: const Text("Азбучно"),
        onTap: () {
          controller.sortAlphabetically();
          controller.onUpdate();
        },
      ),
    ],
  );
}

void showFontSizeMenu(BuildContext context, RelativeRect position) {
  showMenu<String>(
    context: context,
    position: position,
    items: [
      PopupMenuItem(
        child: const Text("Малък"),
        onTap: () => controller.setFontSize(0),
      ),
      PopupMenuItem(
        child: const Text("Среден"),
        onTap: () => controller.setFontSize(1),
      ),
      PopupMenuItem(
        child: const Text("Голям"),
        onTap: () => controller.setFontSize(2),
      ),
    ],
  );
}

void showCategoriesMenu(BuildContext context, RelativeRect position) {
  showMenu<String>(
    context: context,
    position: position,
    items: [
      PopupMenuItem(child: const Text("Всички"), onTap: () => controller.filterBy(null)),
      PopupMenuItem(child: const Text("Бележки"), onTap: () => controller.filterBy(ItemType.note)),
      PopupMenuItem(child: const Text("Задачи"), onTap: () => controller.filterBy(ItemType.task)),
      PopupMenuItem(child: const Text("Идеи"), onTap: () => controller.filterBy(ItemType.idea)),
      PopupMenuItem(child: const Text("Цели"), onTap: () => controller.filterBy(ItemType.goal)),
      PopupMenuItem(child: const Text("Напомняния"), onTap: () => controller.filterBy(ItemType.reminder)),
    ],
  );
}