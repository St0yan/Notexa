import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/pages/home_page.dart';
import '/models/base_item.dart';
import '/models/note_item.dart';
import '/models/task_item.dart';
import '/models/idea_item.dart';
import '/models/reminder_item.dart';
import '/models/goal_item.dart';
import '/models/deleted_item_marker.dart';
import '/services/notification_service.dart';
import '/pages/home_controller.dart';
import '/pages/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await Hive.initFlutter();

  Hive.registerAdapter(ItemTypeAdapter());
  Hive.registerAdapter(BaseItemAdapter());
  Hive.registerAdapter(NoteItemAdapter());
  Hive.registerAdapter(TaskItemAdapter());
  Hive.registerAdapter(IdeaItemAdapter());
  Hive.registerAdapter(ReminderItemAdapter());
  Hive.registerAdapter(GoalItemAdapter());
  Hive.registerAdapter(DeletedItemMarkerAdapter());

  //await Hive.deleteBoxFromDisk('items');
  //await Hive.openBox<String>('items');

  try {
    await Supabase.initialize(
      url: 'https://sbugqqhhfjzrbjmjtczc.supabase.co',
      anonKey: 'sb_publishable_Yye4EaY186Tzm2ju4UDWLg_0Ytt0Jdf',
    );

    await Supabase.instance.client.auth.signInWithPassword(
      email: "test@notexa.app",
      password: "12345678",
    );
  } catch (_) {
    // офлайн → продължаваме
  }

  final controller = HomeController();
  await controller.init();

  runApp(Notexa(controller));
}

class Notexa extends StatefulWidget {
  final HomeController controller;

  const Notexa(this.controller, {super.key});

  @override
  State<Notexa> createState() => _NotexaState();
}

class _NotexaState extends State<Notexa>
    with WidgetsBindingObserver {

  bool _locked = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    widget.controller.onThemeChanged = () {
      setState(() {});
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setState(() {
        _locked = true;
      });
    }
  }

  void _unlockApp() {
    if (!mounted) return;

    setState(() {
      _locked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: widget.controller.currentTheme,
      theme: lightTheme,
      darkTheme: darkTheme,

      home: _locked
          ? LockScreen(
              controller: widget.controller,
              onUnlocked: _unlockApp,
            )
          : HomePage(
              controller: widget.controller,
            ),
    );
  }

  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Inter',

    colorScheme: ColorScheme.dark(
      primary: Colors.tealAccent.shade200,
      secondary: Colors.tealAccent.shade100,
      surface: Colors.black,
      onSurface: Colors.white,
    ),

    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey.shade900,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: Colors.grey.shade900,
      textStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.grey.shade900,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))
      ),
    ),
  );

  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Inter',

    colorScheme: ColorScheme.light(
      primary: Colors.blueGrey.shade700,
      secondary: Colors.teal.shade600,
      surface: Colors.white,
      onSurface: Colors.black,
    ),

    scaffoldBackgroundColor: Colors.grey.shade100,
    cardColor: Colors.white,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      textStyle: const TextStyle(color: Colors.black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}