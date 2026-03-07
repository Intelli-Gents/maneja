import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF3730A3); 
  static const Color background = Color(0xFFF8FAFF);
  static const Color textDark = Color(0xFF111827);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: const Color(0xFF4F46E5),
      surface: background, // Updated from background
      onSurface: textDark,
    );

    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      
      // FIX: Changed CardTheme to CardThemeData
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),

      textTheme: base.textTheme.apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}