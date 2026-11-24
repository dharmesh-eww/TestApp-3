import 'package:flutter/material.dart';

class AppTheme {
  static bool _darkMode = false;
  static void setDarkMode(bool enabled) => _darkMode = enabled;

  static Color get ink => _darkMode ? const Color(0xFFF7F1E8) : const Color(0xFF2D2924);
  static Color get muted => _darkMode ? const Color(0xFFB8AEA2) : const Color(0xFF82796E);
  static Color get paper => _darkMode ? const Color(0xFF171714) : const Color(0xFFF7F4ED);
  static Color get card => _darkMode ? const Color(0xFF24231F) : const Color(0xFFFFFEFA);
  static const terracotta = Color(0xFFB85E43);
  static Color get olive => _darkMode ? const Color(0xFFB1BD91) : const Color(0xFF687A4E);
  static Color get line => _darkMode ? const Color(0xFF3D3931) : const Color(0xFFE9E2D7);
  static const pagePadding = 22.0;
  static const cardRadius = 24.0;
  static const controlRadius = 16.0;

  static ThemeData get dark => _buildTheme(Brightness.dark);
  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF171714) : const Color(0xFFF7F4ED);
    final surface = isDark ? const Color(0xFF24231F) : const Color(0xFFFFFEFA);
    final foreground = isDark ? const Color(0xFFF7F1E8) : const Color(0xFF2D2924);
    final secondary = isDark ? const Color(0xFFB8AEA2) : const Color(0xFF82796E);
    final border = isDark ? const Color(0xFF3D3931) : const Color(0xFFE9E2D7);
    final scheme = ColorScheme.fromSeed(
      seedColor: terracotta,
      brightness: brightness,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: TextTheme(
        displayLarge: TextStyle(color: foreground, fontSize: 38, height: 1.04, fontWeight: FontWeight.w700, letterSpacing: -1.5, fontFamily: 'Georgia'),
        headlineLarge: TextStyle(color: foreground, fontSize: 32, height: 1.08, fontWeight: FontWeight.w700, letterSpacing: -1.0, fontFamily: 'Georgia'),
        headlineMedium: TextStyle(color: foreground, fontSize: 26, height: 1.12, fontWeight: FontWeight.w700, fontFamily: 'Georgia'),
        titleLarge: TextStyle(color: foreground, fontSize: 19, height: 1.2, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: foreground, fontSize: 15, height: 1.25, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: foreground, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: secondary, fontSize: 13, height: 1.45),
        labelLarge: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: .1),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: foreground, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: terracotta.withOpacity(isDark ? .25 : .12),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
          color: states.contains(WidgetState.selected) ? terracotta : secondary,
        )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected) ? terracotta : secondary,
        )),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        hintStyle: TextStyle(color: secondary.withOpacity(.8), fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(controlRadius), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(controlRadius), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(controlRadius), borderSide: const BorderSide(color: terracotta, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: terracotta,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: foreground,
        contentTextStyle: TextStyle(color: background),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: terracotta.withOpacity(isDark ? .24 : .13),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelStyle: TextStyle(color: foreground, fontWeight: FontWeight.w600, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      ),
    );
  }
}

/// Shared timing and easing tokens for motion throughout Gather.
abstract final class AppMotion {
  static const page = Duration(milliseconds: 360);
  static const quick = Duration(milliseconds: 220);
  static const enter = Cubic(0.20, 0.75, 0.25, 1);
  static const exit = Cubic(0.4, 0.0, 1, 1);
}
