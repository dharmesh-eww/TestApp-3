import 'package:flutter/material.dart';

class AppTheme {
  static bool _darkMode = false;
  static void setDarkMode(bool enabled) => _darkMode = enabled;
  static Color get ink => _darkMode ? const Color(0xFFF2EDE6) : const Color(0xFF30251F);
  static Color get muted => _darkMode ? const Color(0xFFB9ADA2) : const Color(0xFF82756C);
  static Color get paper => _darkMode ? const Color(0xFF171411) : const Color(0xFFF8F5EF);
  static Color get card => _darkMode ? const Color(0xFF24201C) : const Color(0xFFFFFEFA);
  static const terracotta = Color(0xFFB85E43);
  static Color get olive => _darkMode ? const Color(0xFFA7B58A) : const Color(0xFF68724D);
  static Color get line => _darkMode ? const Color(0xFF3B332D) : const Color(0xFFE9E2D8);

  static const pagePadding = 20.0;
  static const cardRadius = 20.0;
  static const controlRadius = 14.0;

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: terracotta, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF171411),
        cardTheme: CardThemeData(color: const Color(0xFF24201C), elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius), side: const BorderSide(color: Color(0xFF3B332D)))),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: terracotta,
          brightness: Brightness.light,
          surface: paper,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: ink, fontSize: 34, height: 1.08,
            fontWeight: FontWeight.w700, letterSpacing: -1.2,
            fontFamily: 'Georgia',
          ),
          headlineMedium: TextStyle(
            color: ink, fontSize: 27, height: 1.12,
            fontWeight: FontWeight.w700, fontFamily: 'Georgia',
          ),
          titleLarge: TextStyle(
            color: ink, fontSize: 19, fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            color: ink, fontSize: 15, fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(color: ink, fontSize: 15, height: 1.45),
          bodyMedium: TextStyle(color: muted, fontSize: 13, height: 1.4),
          labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: paper, foregroundColor: ink, elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: card,
          indicatorColor: terracotta.withOpacity(.13),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
            side: BorderSide(color: line),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(controlRadius),
            borderSide: BorderSide(color: line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(controlRadius),
            borderSide: BorderSide(color: line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(controlRadius),
            borderSide: const BorderSide(color: terracotta, width: 1.4),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ink,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: line,
          thickness: 1,
          space: 1,
        ),
      );
}

/// Shared timing and easing tokens for motion throughout Gather.
abstract final class AppMotion {
  static const page = Duration(milliseconds: 280);
  static const quick = Duration(milliseconds: 180);
  static const enter = Cubic(0.20, 0.75, 0.25, 1);
  static const exit = Cubic(0.4, 0.0, 1, 1);
}
