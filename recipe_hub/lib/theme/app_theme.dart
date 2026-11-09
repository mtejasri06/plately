import 'package:flutter/material.dart';

/// Central place for the application's look and feel.
class AppTheme {
  static const Color spinach = Color(0xFF1A22A8);
  static const Color turmeric = Color(0xFFF2B01E);
  static const Color chili = Color(0xFFD6402F);
  static const Color paper = Color(0xFFFDF6EE);
  static const Color ink = Color(0xFF16193D);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: spinach,
      brightness: Brightness.light,
    ).copyWith(
      primary: spinach,
      secondary: turmeric,
      error: chili,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFFD9D3E8),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: paper,

      // Uses Flutter's default font to avoid font errors.
      textTheme: base.textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(
            color: spinach,
            width: 2,
          ),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: chili),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(
            color: chili,
            width: 2,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: spinach,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}