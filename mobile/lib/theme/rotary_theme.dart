import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RotaryTheme {
  static const Color blue = Color(0xFF17458F);
  static const Color azure = Color(0xFF0067C8);
  static const Color gold = Color(0xFFF7A81B);

  static const Color background = Color(0xFF0A1322);
  static const Color surface = Color(0xFF121D33);
  static const Color surfaceHigh = Color(0xFF1A2847);
  static const Color outline = Color(0xFF233457);

  static const Color textPrimary = Color(0xFFF2F5FA);
  static const Color textMuted = Color(0xFF8C9AB5);

  static const double radius = 18;

  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: background,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: gold,
      onPrimary: background,
      primaryContainer: blue,
      onPrimaryContainer: textPrimary,
      secondary: azure,
      onSecondary: textPrimary,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textMuted,
      surfaceContainerHighest: surfaceHigh,
      outline: outline,
      outlineVariant: outline,
      error: Color(0xFFFF6B6B),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
    );

    final text = base.textTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: text.bodyMedium?.copyWith(height: 1.4),
        labelSmall: text.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlayStyle,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: background,
          minimumSize: const Size.fromHeight(52),
          textStyle: text.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceHigh,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: outline, thickness: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: gold,
        linearTrackColor: surfaceHigh,
        circularTrackColor: Colors.transparent,
      ),
    );
  }
}
