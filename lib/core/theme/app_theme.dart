/// Centralized app theme using Material 3.
///
/// Primary brand color is a deep teal (#00695C). Both light and dark themes
/// are derived from [ColorScheme.fromSeed], which automatically generates a
/// harmonious palette and adapts to the system brightness setting.
///
/// Typography uses Google Fonts' "Inter" for a clean, modern look.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The brand's primary deep-teal seed color.
const Color kPrimaryColor = Color(0xFF00695C);

/// Secondary accent — a lighter teal for supporting elements.
const Color kSecondaryColor = Color(0xFF48A999);

/// Warning / error color for destructive actions.
const Color kErrorColor = Color(0xFFD32F2F);

/// Builds the light [ThemeData].
ThemeData buildLightTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    brightness: Brightness.light,
  );
  return _buildThemeFromScheme(scheme);
}

/// Builds the dark [ThemeData].
ThemeData buildDarkTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    brightness: Brightness.dark,
  );
  return _buildThemeFromScheme(scheme);
}

/// Shared theme configuration applied to both light and dark color schemes.
ThemeData _buildThemeFromScheme(ColorScheme scheme) {
  final TextTheme baseTextTheme = GoogleFonts.interTextTheme();
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: baseTextTheme,

    // ── Card styling ──
    // Subtle bordered cards with rounded corners and a soft shadow for a
    // modern, premium look in both light and dark themes.
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: scheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // ── Input field styling ──
    // Rounded, filled text fields with clear focus states.
    // All text colors are explicitly set from the ColorScheme so they remain
    // visible in both light and dark themes (fixes black-on-dark invisibility).
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      hintStyle: GoogleFonts.inter(color: scheme.onSurfaceVariant),
      labelStyle: GoogleFonts.inter(color: scheme.onSurface),
      floatingLabelStyle: GoogleFonts.inter(color: scheme.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // ── Elevated button styling ──
    // Full-width, tall buttons with rounded corners.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── App bar styling ──
    // Flat, clean app bar that blends with the surface.
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
  );
}
