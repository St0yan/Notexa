import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/pages/home_page.dart';
import '/models/base_item.dart';
import '/models/deleted_item_marker.dart';
import '/services/notification_service.dart';
import '/pages/home_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await Hive.initFlutter();

  Hive.registerAdapter(ItemTypeAdapter());
  Hive.registerAdapter(DeletedItemMarkerAdapter());

  //await Hive.deleteBoxFromDisk('items');
  await Hive.openBox<String>('items');

  await Supabase.initialize(
      url: 'https://sbugqqhhfjzrbjmjtczc.supabase.co',
      publishableKey: 'sb_publishable_Yye4EaY186Tzm2ju4UDWLg_0Ytt0Jdf',
    );
  await Supabase.instance.client.auth.signInWithPassword(
        email: "test@notexa.app",
        password: "12345678",
      );

  final controller = HomeController(onUpdate: () {});
  await controller.init();
  HomeController.instance = controller;

  runApp(const Notexa());
}

class Notexa extends StatefulWidget {
  const Notexa({super.key});

  @override
  State<Notexa> createState() => _NotexaState();
}

class _NotexaState extends State<Notexa> {
  @override
  void initState() {
    super.initState();

    HomeController.instance.onThemeChanged = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      themeMode: HomeController.instance.currentTheme,
      theme: lightTheme,
      darkTheme: darkTheme,
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
      background: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
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
      background: Colors.grey.shade100,
      onSurface: Colors.black,
      onBackground: Colors.black,
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