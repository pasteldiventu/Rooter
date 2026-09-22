import 'package:flutter/material.dart';

class RotaryTheme {
  static const Color blue = Color(0xFF17458F);
  static const Color gold = Color(0xFFF7A81B);
  static const Color cream = Color(0xFFF5F7FB);

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: blue,
      primary: blue,
      secondary: gold,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: blue,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: blue),
    );
  }
}
