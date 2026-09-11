import 'package:flutter/material.dart';
import '../models/goal_item.dart';

class AddGoalPage extends StatefulWidget {
  final GoalItem? editItem;
  const AddGoalPage({this.editItem, super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.editItem != null) {
      _titleCtrl.text = widget.editItem!.title;
      _textCtrl.text = widget.editItem!.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final goal = GoalItem(
                id: widget.editItem?.id ?? UniqueKey().toString(),
                createdAt: widget.editItem?.createdAt ?? DateTime.now(),
                title: _titleCtrl.text,
                text: _textCtrl.text,
              );

              Navigator.pop(context, goal);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Целта е запазена!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  margin: EdgeInsets.all(12),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: "Заглавие на целта...",
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _textCtrl,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Описание на целта...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}