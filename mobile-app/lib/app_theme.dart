import 'package:flutter/material.dart';

const ink = Color(0xFF182B2A);
const mutedInk = Color(0xFF667573);
const forest = Color(0xFF1C6257);
const lime = Color(0xFFC6E768);
const coral = Color(0xFFE77962);
const canvas = Color(0xFFF4F6F1);
const line = Color(0xFFE1E7DF);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: forest,
      brightness: Brightness.light,
      surface: Colors.white,
      primary: forest,
      secondary: lime,
      error: coral,
    ),
    scaffoldBackgroundColor: canvas,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: ink,
        fontWeight: FontWeight.w700,
        height: 1.12,
      ),
      titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: ink, height: 1.4),
      bodySmall: TextStyle(color: mutedInk, height: 1.35),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: forest, width: 1.6),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: lime.withValues(alpha: 0.38),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected) ? forest : mutedInk,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
