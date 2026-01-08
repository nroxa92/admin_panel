// FILE: lib/config/theme.dart
// OPIS: Generator tema.
// FIXES: Zamijenjen deprecated 'withOpacity' s 'withValues(alpha: ...)'.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData generateTheme({
    required Color primaryColor,
    required Color backgroundColor,
  }) {
    // 1. Detekcija svjetline
    final bool isDark = backgroundColor.computeLuminance() < 0.5;
    final Brightness brightness = isDark ? Brightness.dark : Brightness.light;

    // 2. Boje teksta
    final Color textColor =
        isDark ? const Color(0xFFEEEEEE) : const Color(0xFF121212);
    final Color textGrey =
        isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666);

    // 3. Pametni kontrast za kartice
    Color cardSurface;
    if (isDark) {
      if (backgroundColor == Colors.black) {
        cardSurface = const Color(0xFF1A1A1A);
      } else {
        // FIX: Zamjena withOpacity -> withValues(alpha:)
        cardSurface = Color.alphaBlend(
            Colors.white.withValues(alpha: 0.05), backgroundColor);
      }
    } else {
      cardSurface = Colors.white;
    }

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: primaryColor,
      onPrimary: isDark ? Colors.black : Colors.white,
      surface: backgroundColor,
      onSurface: textColor,
      surfaceContainer: cardSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      canvasColor: backgroundColor,
      colorScheme: colorScheme,

      // --- TIPOGRAFIJA ---
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        bodyLarge: GoogleFonts.lato(fontSize: 16, color: textColor),
        bodyMedium: GoogleFonts.lato(fontSize: 14, color: textGrey),
        titleMedium: GoogleFonts.lato(
            fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
      ),

      // --- KARTICE ---
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
      ),

      // --- GUMBI ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
      ),

      // --- INPUT POLJA ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // FIX: Zamjena withOpacity -> withValues(alpha:)
        fillColor: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.1),
        labelStyle: TextStyle(color: textGrey),
        hintStyle: TextStyle(color: textGrey.withValues(alpha: 0.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),

      // --- APP BAR ---
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
