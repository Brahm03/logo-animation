import 'package:animation_lesson/src/core/consts/app_themes.dart';
import 'package:animation_lesson/src/features/home/presentation/home_page.dart';
import 'package:animation_lesson/src/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      home: const SplashScreen(),
    );
  }
}
