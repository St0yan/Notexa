import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/pages/home_page.dart';
import '/models/base_item.dart';
import '/models/goal_item.dart';
import '/models/idea_item.dart';
import '/models/note_item.dart';
import '/models/reminder_item.dart';
import '/models/task_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(NoteItemAdapter());
  Hive.registerAdapter(TaskItemAdapter());
  Hive.registerAdapter(TaskEntryAdapter());
  Hive.registerAdapter(IdeaItemAdapter());
  Hive.registerAdapter(ReminderItemAdapter());
  Hive.registerAdapter(GoalItemAdapter());
  Hive.registerAdapter(ItemTypeAdapter());

  await Hive.openBox<BaseItem>('items');

  await Supabase.initialize(
    url: 'https://sbugqqhhfjzrbjmjtczc.supabase.co',
    publishableKey: 'sb_publishable_Yye4EaY186Tzm2ju4UDWLg_0Ytt0Jdf',
  );

  await Supabase.instance.client.auth.signInWithPassword(
    email: 'test@notexa.app',
    password: '12345678',
  );

  runApp(const Notexa());
}

class Notexa extends StatelessWidget {
  const Notexa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
    );
  }
}