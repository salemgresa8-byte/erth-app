import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colors.
class AppColors {
  AppColors._();

  /// Imperial Burgundy
  static const Color burgundy = Color(0xFF3F1720);

  /// Warm Marble
  static const Color marble = Color(0xFFF5E6D3);

  // Dark mode surfaces: deep burgundy-tinted blacks.
  static const Color darkBackground = Color(0xFF1A0A0E);
  static const Color darkSurface = Color(0xFF2A1118);

  /// Lighter burgundy tint used as the primary in dark mode for contrast.
  static const Color burgundyLight = Color(0xFFD9A7B0);
}

class AppTheme {
  AppTheme._();

  static ThemeData light({bool isArabic = false}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.burgundy,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.burgundy,
      onPrimary: AppColors.marble,
      secondary: AppColors.marble,
      onSecondary: AppColors.burgundy,
      surface: AppColors.marble,
      onSurface: AppColors.burgundy,
    );
    return _build(scheme, isArabic, AppColors.marble);
  }

  static ThemeData dark({bool isArabic = false}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.burgundy,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.burgundyLight,
      onPrimary: AppColors.burgundy,
      secondary: AppColors.marble,
      onSecondary: AppColors.burgundy,
      surface: AppColors.darkSurface,
      onSurface: AppColors.marble,
    );
    return _build(scheme, isArabic, AppColors.darkBackground);
  }

  static ThemeData _build(ColorScheme scheme, bool isArabic, Color background) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
    );
    final textTheme = _textTheme(base.textTheme, isArabic)
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.brightness == Brightness.light
            ? AppColors.burgundy
            : AppColors.darkSurface,
        foregroundColor: AppColors.marble,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: AppColors.marble),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: textTheme.labelLarge,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.brightness == Brightness.light
            ? Colors.white.withValues(alpha: 0.5)
            : AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.2)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.onSurface.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }

  /// Classic serif pairing:
  /// - Arabic: Amiri (Naskh, classic calligraphic serif)
  /// - English: Playfair Display for headings, Cormorant Garamond for body
  static TextTheme _textTheme(TextTheme base, bool isArabic) {
    if (isArabic) {
      return GoogleFonts.amiriTextTheme(base);
    }
    final body = GoogleFonts.cormorantGaramondTextTheme(base);
    final heading = GoogleFonts.playfairDisplayTextTheme(base);
    return body.copyWith(
      displayLarge: heading.displayLarge,
      displayMedium: heading.displayMedium,
      displaySmall: heading.displaySmall,
      headlineLarge: heading.headlineLarge,
      headlineMedium: heading.headlineMedium,
      headlineSmall: heading.headlineSmall,
      titleLarge: heading.titleLarge,
    );
  }
}
