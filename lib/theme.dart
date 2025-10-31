import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Central theme based on the provided image palette
// Primary: teal/green curve, Secondary: orange curve
class AppTheme {
  // Brand colors extracted from the logo image
  static const Color primary = Color(0xFF1AA7A1); // teal-green
  static const Color secondary = Color(0xFFF37021); // orange
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F9FC);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF111317);
  static const Color muted = Color(0xFF646D87);

  static ThemeData light() {
    final base = ThemeData.light();
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: const Color(0xFFB00020),
      onError: Colors.white,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onBackground,
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: onBackground,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: onBackground,
      ),
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: onPrimary,
        ),
      ),
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: primary.withOpacity(0.12),
        labelStyle: const TextStyle(color: onBackground),
      ),
    );
  }
}
