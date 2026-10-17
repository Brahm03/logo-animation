import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppThemes {
  AppThemes._();

  static final ThemeData light = ThemeData(
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
    ),
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      brightness: Brightness.light,
    ),
  );
}
