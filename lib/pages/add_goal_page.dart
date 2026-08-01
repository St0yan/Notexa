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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
              decoration: const InputDecoration(
                hintText: "Заглавие на целта...",
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _textCtrl,
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