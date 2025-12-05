import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFE9E9EC),
    elevatedButtonTheme: OnboardingNextButtonTheme.lightTheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFF0F465D), width: 2),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0C1C24)),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0C1C24)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    elevatedButtonTheme: OnboardingNextButtonTheme.darkTheme,
  );
}

class OnboardingNextButtonTheme {
  OnboardingNextButtonTheme._();

  static ElevatedButtonThemeData lightTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
      backgroundColor: Color(0xFF0F465D),
      foregroundColor: Colors.white,
      elevation: 2, // to chyba cień
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4)),
    ),
  );
  static ElevatedButtonThemeData darkTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
      backgroundColor: Color(0xFF0F465D),
      foregroundColor: Colors.white,
      elevation: 2, // to chyba cień
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4)),
    ),
  );
}
