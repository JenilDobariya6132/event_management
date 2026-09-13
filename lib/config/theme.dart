// lib/config/theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra-Luxury Royal Wedding Palette
  static const Color primary = Color(0xFF4A1027);        // Imperial Deep Burgundy
  static const Color primaryDark = Color(0xFF2D0917);    // Midnight Burgundy
  static const Color primaryLight = Color(0xFF7A2042);   // Crimson Velvet
  static const Color accent = Color(0xFFD4AF37);         // Royal Metallic Gold
  static const Color accentLight = Color(0xFFF7E7B4);    // Champagne Gold Shimmer
  static const Color accentDark = Color(0xFFAA820A);     // Deep Antique Gold
  static const Color rose = Color(0xFFE8A0A8);          // Dusky Rose Pink
  static const Color roseLight = Color(0xFFFFF2F4);     // Blush Cream
  static const Color background = Color(0xFFFDFBF7);    // Ivory Porcelain Cream
  static const Color cardBg = Color(0xFFFFFFFF);        // Pure Crisp White
  static const Color textDark = Color(0xFF1F1A1C);      // Dark Velvet Charcoal
  static const Color textMuted = Color(0xFF6E6569);     // Warm Taupe Grey
  static const Color success = Color(0xFF1B6B40);       // Royal Emerald Green
  static const Color warning = Color(0xFFD97706);       // Warm Amber Gold
  static const Color error = Color(0xFFC5221F);         // Deep Ruby Red

  // Luxurious Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B1731), Color(0xFF380C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF7E7B4), Color(0xFFD4AF37), Color(0xFFAA820A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFFFF2F4), Color(0xFFFBE4E7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC1F1A1C), Color(0xF71F1A1C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Luxury Card Shadows
  static List<BoxShadow> luxuryShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.07),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: accent.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> goldGlowShadow = [
    BoxShadow(
      color: accent.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // Luxury Box Decorations
  static BoxDecoration glassCardDecoration = BoxDecoration(
    color: cardBg.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: accent.withValues(alpha: 0.25), width: 1),
    boxShadow: luxuryShadow,
  );

  static BoxDecoration goldBorderDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
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
          side: BorderSide(color: primary.withValues(alpha: 0.06), width: 1),
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
          borderSide: const BorderSide(color: accent, width: 2),
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

