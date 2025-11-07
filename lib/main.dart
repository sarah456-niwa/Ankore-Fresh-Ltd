// main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AnkoleFreshApp());
}

class AnkoleFreshApp extends StatelessWidget {
  const AnkoleFreshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ankore Fresh',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}