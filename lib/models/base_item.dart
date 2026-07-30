enum ItemType {
  note,
  task,
  idea,
  reminder,
  goal,
}

abstract class BaseItem {
  final String id;
  final ItemType type;
  final DateTime createdAt;

  BaseItem({
    required this.id,
    required this.type,
    required this.createdAt,
  });
}