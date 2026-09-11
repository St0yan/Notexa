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
              final idea = IdeaItem(
                id: widget.editItem?.id ?? UniqueKey().toString(),
                createdAt: widget.editItem?.createdAt ?? DateTime.now(),
                text: _textCtrl.text,
              );

              Navigator.pop(context, idea);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Идеята е запазена!'),
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
        child: TextField(
          controller: _textCtrl,
          textCapitalization: TextCapitalization.sentences,
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