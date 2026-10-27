import 'package:flutter/material.dart';

class AppTheme {
  // Brand
  static const Color primary = Color(0xFF0F6B5F);
  static const Color primaryLight = Color(0xFF1B8A7A);
  static const Color primaryDark = Color(0xFF0A4F46);
  static const Color accent = Color(0xFFFFB020);
  static const Color danger = Color(0xFFE53935);
  static const Color success = Color(0xFF2E9B5B);
  static const Color info = Color(0xFF2F6FED);

  static const Color bg = Color(0xFFF4F6F8);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF1A202C);
  static const Color text2 = Color(0xFF4A5568);
  static const Color muted = Color(0xFF8A94A6);
  static const Color border = Color(0xFFE2E8F0);

  static const double radiusSm = 10;
  static const double radius = 16;
  static const double radiusLg = 24;

  static LinearGradient get headerGradient => const LinearGradient(
        colors: [primaryDark, primary, primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light).copyWith(
        primary: primary,
        secondary: accent,
        error: danger,
        surface: surface,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.2),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        shadowColor: Colors.black12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSm), borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSm), borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSm), borderSide: const BorderSide(color: primary, width: 1.6)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSm), borderSide: const BorderSide(color: danger)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: text2, fontSize: 14),
        hintStyle: const TextStyle(color: muted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary, textStyle: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: 0.12),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: border)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: selected ? primary : muted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primary : muted, size: 24);
        }),
        elevation: 8,
        height: 68,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: text, letterSpacing: -0.5),
        headlineMedium: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: text, letterSpacing: -0.3),
        titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: text),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text),
        bodyLarge: const TextStyle(fontSize: 15, color: text, height: 1.4),
        bodyMedium: const TextStyle(fontSize: 14, color: text2, height: 1.4),
        bodySmall: const TextStyle(fontSize: 12, color: muted, height: 1.3),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
    );
  }

  static BoxShadow get cardShadow => BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.06),
        blurRadius: 18,
        offset: const Offset(0, 6),
      );

  static BoxShadow get softShadow => BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      );
}