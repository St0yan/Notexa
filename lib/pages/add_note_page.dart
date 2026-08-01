import 'package:flutter/material.dart';
import '../models/note_item.dart';

class AddNotePage extends StatefulWidget {
  final NoteItem? editItem;

  const AddNotePage({this.editItem, super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late TextEditingController titleController;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.editItem?.title ?? "");
    textController = TextEditingController(text: widget.editItem?.text ?? "");
  }

  void _save() {
    final idea = NoteItem(
      id: UniqueKey().toString(),
      createdAt: DateTime.now(),
      title: titleController.text,
      text: textController.text
    );

    Navigator.pop(context, idea);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editItem == null ? "Нова бележка" : "Редакция"),
      ),
      body: Column(
        children: [
          TextField(controller: titleController, decoration: InputDecoration(hintText: 'Заглавие'),),
          TextField(controller: textController, decoration: InputDecoration(hintText: 'Бележка'), maxLines: null,),
          ElevatedButton(onPressed: _save, child: Text("Запази")),
        ],
      ),
    );
  }
}