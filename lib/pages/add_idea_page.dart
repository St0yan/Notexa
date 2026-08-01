import 'package:flutter/material.dart';
import '../models/idea_item.dart';

class AddIdeaPage extends StatefulWidget {
  final IdeaItem? editItem;

  const AddIdeaPage({this.editItem, super.key});

  @override
  State<AddIdeaPage> createState() => _AddIdeaPageState();
}

class _AddIdeaPageState extends State<AddIdeaPage> {
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.editItem != null) {
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
              final idea = IdeaItem(
                id: widget.editItem?.id ?? UniqueKey().toString(),
                createdAt: widget.editItem?.createdAt ?? DateTime.now(),
                text: _textCtrl.text,
              );

              Navigator.pop(context, idea);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _textCtrl,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: "Идея...",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}