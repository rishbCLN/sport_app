import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// PRISM App Theme — wires up Flutter's ThemeData from PrismColors.
class PrismTheme {
  PrismTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PrismColors.abyss,
      colorScheme: ColorScheme.dark(
        primary: PrismColors.voltGreen,
        secondary: PrismColors.cyanBlitz,
        tertiary: PrismColors.magentaFlare,
        surface: PrismColors.pitch,
        background: PrismColors.abyss,
        error: PrismColors.redAlert,
        onPrimary: PrismColors.voidBlack,
        onSecondary: PrismColors.voidBlack,
        onSurface: PrismColors.ghostWhite,
        onBackground: PrismColors.ghostWhite,
        outline: PrismColors.concrete,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(ThemeData.dark().textTheme)
          .copyWith(
        displayLarge: GoogleFonts.orbitron(
          color: PrismColors.ghostWhite,
          fontWeight: FontWeight.w900,
          fontSize: 48,
        ),
        displayMedium: GoogleFonts.orbitron(
          color: PrismColors.ghostWhite,
          fontWeight: FontWeight.w800,
          fontSize: 36,
        ),
        headlineLarge: GoogleFonts.rajdhani(
          color: PrismColors.ghostWhite,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          color: PrismColors.ghostWhite,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
        titleLarge: GoogleFonts.rajdhani(
          color: PrismColors.ghostWhite,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        bodyLarge: GoogleFonts.inter(
          color: PrismColors.steelGray,
          fontSize: 15,
        ),
        bodyMedium: GoogleFonts.inter(
          color: PrismColors.steelGray,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.rajdhani(
          color: PrismColors.voltGreen,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          fontSize: 13,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: PrismColors.ghostWhite,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: PrismColors.ghostWhite,
          letterSpacing: 1.5,
        ),
        iconTheme:
            const IconThemeData(color: PrismColors.ghostWhite, size: 24),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: PrismColors.pitch,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: PrismColors.pitch,
        surfaceTintColor: Colors.transparent,
        indicatorColor: PrismColors.voltGreen.withOpacity(0.15),
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
                size: 26, color: PrismColors.voltGreen);
          }
          return IconThemeData(
              size: 22, color: PrismColors.steelGray);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.rajdhani(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: PrismColors.voltGreen,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.rajdhani(
            fontSize: 11,
            color: PrismColors.steelGray,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: PrismColors.concrete,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PrismColors.concrete,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: PrismColors.dimGray, width: 1),
          borderRadius: BorderRadius.zero,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: PrismColors.dimGray, width: 1),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: PrismColors.voltGreen, width: 1.5),
          borderRadius: BorderRadius.zero,
        ),
        labelStyle:
            GoogleFonts.rajdhani(color: PrismColors.steelGray, fontSize: 14),
        hintStyle:
            GoogleFonts.rajdhani(color: PrismColors.dimGray, fontSize: 14),
        prefixIconColor: PrismColors.steelGray,
        suffixIconColor: PrismColors.steelGray,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: PrismColors.pitch,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
        titleTextStyle: GoogleFonts.orbitron(
          color: PrismColors.ghostWhite,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: PrismColors.steelGray,
          fontSize: 14,
        ),
      ),
    );
  }
}
