import 'package:flutter/material.dart';

import 'tech_palette.dart';

/// 全站固定的深色表面与状态色；背景渐变由 TechPalette 决定。
class AppColors {
  const AppColors._();

  static const canvas = Color(0xFF060912);
  static const background = Color(0xFF0B1120);
  static const ink = Color(0xFFF2F5FF);
  static const muted = Color(0xFFA4AEC9);
  static const primary = Color(0xFF6C8CFF);
  static const accent = Color(0xFFFF9A6B);
  static const mint = Color(0xFF3EE0C0);
  static const danger = Color(0xFFFF5C77);
  static const card = Color(0xE6151B2D);
  static const surface = Color(0xFF151B2D);
  static const line = Color(0xFF2B3552);
  static const star = Color(0xFFFFC24B);
}

class AppTheme {
  const AppTheme._();

  static ThemeData dark(TechPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: palette.primary,
      secondary: AppColors.mint,
      surface: AppColors.surface,
      error: AppColors.danger,
      onSurface: AppColors.ink,
    );
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: const Color(0xFF061310),
          minimumSize: const Size(0, 56),
          elevation: 10,
          shadowColor: AppColors.mint.withValues(alpha: 0.55),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.35), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(0, 52),
          backgroundColor: AppColors.card,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.muted),
      ),
      textTheme: base.textTheme.copyWith(
        displaySmall: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
          color: AppColors.ink,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyMedium: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted),
        bodySmall: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.muted),
      ),
    );
  }
}
