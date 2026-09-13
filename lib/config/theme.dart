// lib/config/theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra-Luxury Sage & Dark Olive Palette (#EBEEDF & #333C30)
  static const Color primary = Color(0xFF333C30);        // Dark Forest Olive (#333C30)
  static const Color primaryDark = Color(0xFF222920);    // Midnight Olive (#222920)
  static const Color primaryLight = Color(0xFF4B5747);   // Soft Forest Green (#4B5747)
  static const Color accent = Color(0xFF4B5747);         // Deep Olive Accent (#4B5747)
  static const Color accentLight = Color(0xFFDFE4D4);    // Light Olive Tint (#DFE4D4)
  static const Color accentDark = Color(0xFF222920);     // Dark Antique Olive (#222920)
  static const Color rose = Color(0xFF9EAA96);           // Muted Sage (#9EAA96)
  static const Color roseLight = Color(0xFFF4F6EE);      // Very Light Sage Cream (#F4F6EE)
  static const Color background = Color(0xFFEBEEDF);     // Sage Porcelain Cream (#EBEEDF)
  static const Color cardBg = Color(0xFFFFFFFF);         // Pure Crisp White
  static const Color textDark = Color(0xFF1E241C);       // Dark Pine Charcoal
  static const Color textMuted = Color(0xFF5B6557);      // Muted Sage Grey
  static const Color success = Color(0xFF2C6B38);        // Emerald Olive Green
  static const Color warning = Color(0xFFC07020);        // Warm Amber
  static const Color error = Color(0xFFC5221F);          // Deep Ruby Red

  // Luxurious Sage & Olive Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF333C30), Color(0xFF222920)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFEBEEDF), Color(0xFFDFE4D4), Color(0xFFC8D1BB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFF4F6EE), Color(0xFFEBEEDF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC222920), Color(0xF71E241C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Luxury Card Shadows
  static List<BoxShadow> luxuryShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> goldGlowShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // Luxury Box Decorations
  static BoxDecoration glassCardDecoration = BoxDecoration(
    color: cardBg.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: primary.withValues(alpha: 0.2), width: 1),
    boxShadow: luxuryShadow,
  );

  static BoxDecoration goldBorderDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: primary.withValues(alpha: 0.3), width: 1.2),
    boxShadow: luxuryShadow,
  );

  static ThemeData get luxuryTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: GoogleFonts.playfairDisplay().fontFamily,

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primary,
          letterSpacing: 0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primary.withValues(alpha: 0.08), width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(
          color: textMuted.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
    );
  }
}
