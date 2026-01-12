import 'package:flutter/material.dart';

/// Centralized theme & colors for the ARA app.
class ARAColors {
  static const Color brand = Color(0xFFF3A93B);
  static const Color brandDark = Color(0xFFD08112);
  static const Color brandDeep = Color(0xFFC5710A);

  static const Color ink = Color(0xFF1E2A36);
  static const Color inkStrong = Color(0xFF37474F);
  static const Color inkSoft = Color(0xFF324150);
  static const Color subInk = Color(0xFF5C6B7A);

  static const Color bg = Color(0xFFF8F5F0);
  static const Color cardBg = Colors.white;
  static const Color surfaceWarm = Color(0xFFF8F5F0);
  static const Color surfaceWarmAlt = Color(0xFFF1EEE7);
  static const Color surfaceWarmSoft = Color(0xFFF6F1E8);
  static const Color surfaceWarmTint = Color(0xFFF0E6D6);
  static const Color surfaceCool = Color(0xFFF5F6F8);
  static const Color surfaceCoolSoft = Color(0xFFF2F5F7);

  static const Color success = Color(0xFF66BB6A);
  static const Color successSoft = Color(0xFFB9E0B9);
  static const Color warning = Color(0xFFFB8C00);
  static const Color warningSoft = Color(0xFFEACD8C);
  static const Color dangerSoft = Color(0xFFE7AEB5);
  static const Color danger = Color(0xFFD32F2F);
  static const Color dangerMid = Color(0xFFEF5350);
  static const Color dangerLight = Color(0xFFE57373);

  static const Color infoSurface = Color(0xFFFFF3E0);
  static const Color infoBorder = Color(0xFFFFE0B2);

  static const Color cautionSurface = Color(0xFFFFF3CD);
  static const Color cautionBorder = Color(0xFFFFE69C);
  static const Color cautionText = Color(0xFFB26A00);

  static const Color countdownSurface = Color(0xFFFBE6C8);
  static const Color countdownText = Color(0xFF6D4C41);

  static const Color overlayLight = Color(0x1A000000);
  static const Color overlayDark = Color(0x22FFFFFF);
  static const Color transparent = Colors.transparent;

  static const Color dogAccent = Color(0xFF1976D2);
  static const Color dogAccentLight = Color(0xFF42A5F5);
  static const Color friendly = Color(0xFF43A047);
  static const Color careful = Color(0xFFFB8C00);

  static const Color flagDanger = Color(0xFFD32F2F);
  static const Color flagCaution = Color(0xFFFB8C00);
  static const Color flagQuarantine = Color(0xFF7B1FA2);
  static const Color flagInfo = Color(0xFF1E88E5);

  static const Gradient morningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, brandDark],
  );

  static const Gradient softBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceWarm, surfaceCoolSoft],
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
    ).copyWith(onPrimary: ARAColors.ink);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ARAColors.bg,
      cardColor: ARAColors.cardBg,
      textTheme: Typography.blackMountainView.copyWith(
        headlineMedium: const TextStyle(
          color: ARAColors.ink,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: const TextStyle(
          color: ARAColors.subInk,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ARAColors.bg,
        foregroundColor: ARAColors.ink,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: ARAColors.cardBg,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ARAColors.brand,
          foregroundColor: ARAColors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        height: 70,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        indicatorColor: const Color(0xFFFBE6C8),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? ARAColors.brandDark : Colors.black,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? ARAColors.brandDark : Colors.black,
            fontWeight: FontWeight.w600,
          );
        }),
      ),
    );
  }
}
