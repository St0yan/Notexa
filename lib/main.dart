import 'package:flutter/material.dart';
import '/pages/home_page.dart';

void main() {
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