import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const Flip7App());
}

class Flip7App extends StatelessWidget {
  const Flip7App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flip 7 Score',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          secondary: const Color(0xFFFF9800),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          secondary: const Color(0xFFFF9800),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const StartScreen(),
    );
  }
}
