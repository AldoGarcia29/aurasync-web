import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const AuraSyncApp());
}

class AuraSyncApp extends StatelessWidget {
  const AuraSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AuraSync',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5145CD),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}