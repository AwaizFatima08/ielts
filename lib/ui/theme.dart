import 'package:flutter/material.dart';

/// Design tokens. The exam screens imitate the calm, high-contrast look of
/// the computer-delivered test: white paper, navy chrome, one accent.
abstract final class AppColors {
  static const navy = Color(0xFF1B3557);
  static const accent = Color(0xFFC8102E);
  static const correct = Color(0xFF1E7B45);
  static const incorrect = Color(0xFFB3261E);
  static const flagged = Color(0xFFE08A00);
  static const highlight = Color(0xFFFFF3B0);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.navy, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light ? AppColors.navy : scheme.surface,
        foregroundColor: brightness == Brightness.light ? Colors.white : scheme.onSurface,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
      ),
      cardTheme: const CardThemeData(margin: EdgeInsetsDirectional.only(bottom: AppSpacing.md)),
    );
  }
}
