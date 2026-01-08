import 'package:flutter/material.dart';

/// Centralized theme & colors for the ARA app.
class ARAColors {
  // ─────────────────────────────────────────────
  // Brand
  // ─────────────────────────────────────────────
  static const Color brand = Color(0xFFF3A93B);
  static const Color brandDark = Color(0xFFD08112);
  static const Color brandDeep = Color(0xFFC5710A);

  // ─────────────────────────────────────────────
  // Text
  // ─────────────────────────────────────────────
  static const Color ink = Color(0xFF1E2A36);
  static const Color subInk = Color(0xFF5C6B7A);

  // ─────────────────────────────────────────────
  // Backgrounds / Surfaces
  // ─────────────────────────────────────────────
  static const Color bg = Color(0xFFF9FAFB);
  static const Color cardBg = Colors.white;

  // ─────────────────────────────────────────────
  // Gradients (large visual surfaces only)
  // ─────────────────────────────────────────────
  static const Gradient morningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, brandDark],
  );

  static const Gradient eveningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
  );

  static const Gradient dogGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
  );

  static const Gradient catGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC407A), Color(0xFFC2185B)],
  );
}

class ARATheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ARAColors.brand,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      scaffoldBackgroundColor: ARAColors.bg,
      cardColor: ARAColors.cardBg,

      // ─────────────────────────────────────────────
      // Typography
      // ─────────────────────────────────────────────
      textTheme: Typography.blackMountainView.copyWith(
        headlineMedium: const TextStyle(
          color: ARAColors.ink,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: const TextStyle(
          color: ARAColors.subInk,
        ),
      ),

      // ─────────────────────────────────────────────
      // AppBar (neutral, no glare)
      // ─────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ARAColors.ink,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      // ─────────────────────────────────────────────
      // Cards
      // ─────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: ARAColors.cardBg,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ─────────────────────────────────────────────
      // Buttons
      // ─────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ARAColors.brand,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),

      // ─────────────────────────────────────────────
      // Inputs
      // ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ARAColors.cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: ARAColors.brand, width: 2),
        ),
      ),

      // ─────────────────────────────────────────────
      // Bottom Navigation Bar
      // (calm, iOS-like, no eye strain)
      // ─────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        height: 70,
        elevation: 0,
        indicatorColor: ARAColors.brand.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? ARAColors.brandDeep : ARAColors.subInk,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? ARAColors.brandDeep : ARAColors.subInk,
            fontWeight: FontWeight.w600,
          );
        }),
      ),
    );
  }
}
