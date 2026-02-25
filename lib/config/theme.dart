import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application-wide theme configuration - Premium Black with Lawn Green
class AppTheme {
  // Premium color palette
  static const Color lawnGreen = Color(0xFF7CFC00);
  static const Color premiumBlack = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF0A0A0A);
  static const Color cardBlack = Color(0xFF121212);
  static const Color accentGreen = Color(0xFF9AFF00);

  /// Premium dark theme for the application
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: premiumBlack,
      colorScheme: ColorScheme.dark(
        primary: lawnGreen,
        secondary: accentGreen,
        surface: cardBlack,
        background: premiumBlack,
        onPrimary: premiumBlack,
        onSecondary: premiumBlack,
        onSurface: lawnGreen,
        onBackground: lawnGreen,
        error: const Color(0xFFFF3B30),
        outline: const Color(0xFF2A2A2A),
      ),
      
      // Text theme with lawn green color
      textTheme: GoogleFonts.audiowideTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.audiowide(color: lawnGreen, fontWeight: FontWeight.w900),
        displayMedium: GoogleFonts.audiowide(color: lawnGreen, fontWeight: FontWeight.w700),
        displaySmall: GoogleFonts.audiowide(color: lawnGreen, fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.audiowide(color: lawnGreen, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.audiowide(color: lawnGreen, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.audiowide(color: lawnGreen, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.rajdhani(color: lawnGreen, fontWeight: FontWeight.w700, fontSize: 22),
        titleMedium: GoogleFonts.rajdhani(color: lawnGreen, fontWeight: FontWeight.w600, fontSize: 18),
        titleSmall: GoogleFonts.rajdhani(color: lawnGreen, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: GoogleFonts.rajdhani(color: lawnGreen, fontWeight: FontWeight.w500, fontSize: 16),
        bodyMedium: GoogleFonts.rajdhani(color: lawnGreen, fontWeight: FontWeight.w400, fontSize: 14),
        bodySmall: GoogleFonts.rajdhani(color: lawnGreen.withOpacity(0.7), fontWeight: FontWeight.w400, fontSize: 12),
        labelLarge: GoogleFonts.rajdhani(color: lawnGreen, fontWeight: FontWeight.w600, fontSize: 14),
        labelMedium: GoogleFonts.rajdhani(color: lawnGreen, fontWeight: FontWeight.w500, fontSize: 12),
        labelSmall: GoogleFonts.rajdhani(color: lawnGreen.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 11),
      ),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: premiumBlack,
        foregroundColor: lawnGreen,
        surfaceTintColor: Colors.transparent,
        shadowColor: lawnGreen.withOpacity(0.1),
        titleTextStyle: GoogleFonts.audiowide(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: lawnGreen,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(
          color: lawnGreen,
          size: 24,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: 8,
        color: cardBlack,
        surfaceTintColor: Colors.transparent,
        shadowColor: lawnGreen.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: lawnGreen.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      
      // Floating Action Button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        backgroundColor: lawnGreen,
        foregroundColor: premiumBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        extendedTextStyle: GoogleFonts.rajdhani(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 1,
        ),
      ),
      
      // Navigation Bar theme
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: cardBlack,
        surfaceTintColor: Colors.transparent,
        indicatorColor: lawnGreen.withOpacity(0.2),
        shadowColor: lawnGreen.withOpacity(0.3),
        height: 70,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              size: 28,
              color: lawnGreen,
            );
          }
          return IconThemeData(
            size: 24,
            color: lawnGreen.withOpacity(0.5),
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: lawnGreen,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: lawnGreen.withOpacity(0.5),
          );
        }),
      ),
      
      // Elevated Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lawnGreen,
          foregroundColor: premiumBlack,
          elevation: 6,
          shadowColor: lawnGreen.withOpacity(0.5),
          textStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: lawnGreen,
        size: 24,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: lawnGreen.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lawnGreen.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lawnGreen.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lawnGreen, width: 2),
        ),
        labelStyle: GoogleFonts.rajdhani(color: lawnGreen),
        hintStyle: GoogleFonts.rajdhani(color: lawnGreen.withOpacity(0.5)),
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: lawnGreen,
        circularTrackColor: Color(0xFF1A1A1A),
      ),
    );
  }

  /// Light theme redirects to dark theme for consistent premium look
  static ThemeData get lightTheme => darkTheme;
}
