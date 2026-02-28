import 'package:flutter/material.dart';

/// PRISM Color System — "Voltage Palette"
/// Dark stadium aesthetic with neon sport-specific accents.
class PrismColors {
  PrismColors._();

  // ── Base layers ────────────────────────────────────────────────────────────
  static const Color voidBlack = Color(0xFF000000);
  static const Color abyss = Color(0xFF0A0A0F);
  static const Color pitch = Color(0xFF141419);
  static const Color concrete = Color(0xFF1F1F28);
  static const Color elevated = Color(0xFF2A2A36);

  // ── Neon sport accents ─────────────────────────────────────────────────────
  static const Color voltGreen = Color(0xFF00FF41);    // Football sand / CTA
  static const Color cyanBlitz = Color(0xFF00E0FF);   // Football hard / tech
  static const Color magentaFlare = Color(0xFFFF0080); // Badminton
  static const Color amberShock = Color(0xFFFFA500);  // Cricket
  static const Color redAlert = Color(0xFFFF003C);    // Live match indicator
  static const Color purpleCharge = Color(0xFFBF00FF); // Profile / special

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color ghostWhite = Color(0xFFF0F0F5);
  static const Color steelGray = Color(0xFF8E8E93);
  static const Color dimGray = Color(0xFF48484A);

  // ── Gradient pairs ─────────────────────────────────────────────────────────
  static const List<Color> voltGradient = [
    Color(0xFF00FF41),
    Color(0xFF00C853),
  ];
  static const List<Color> cyanGradient = [
    Color(0xFF00E0FF),
    Color(0xFF0091EA),
  ];
  static const List<Color> magentaGradient = [
    Color(0xFFFF0080),
    Color(0xFFD50000),
  ];
  static const List<Color> amberGradient = [
    Color(0xFFFFA500),
    Color(0xFFFF6D00),
  ];
  static const List<Color> redGradient = [
    Color(0xFFFF003C),
    Color(0xFFB71C1C),
  ];

  // ── Overlay effects ────────────────────────────────────────────────────────
  static const Color scanLine = voltGreen; // at 12–15% opacity
  static const List<Color> hologramShift = [
    Color(0xFF00FFF0),
    Color(0xFFFF00F0),
    Color(0xFF00FF41),
  ];

  // ── Sport-specific accent lookup ──────────────────────────────────────────
  static Color sportAccent(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return voltGreen;
      case 'badminton':
        return magentaFlare;
      case 'cricket':
        return amberShock;
      default:
        return cyanBlitz;
    }
  }

  static List<Color> sportGradient(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return voltGradient;
      case 'badminton':
        return magentaGradient;
      case 'cricket':
        return amberGradient;
      default:
        return cyanGradient;
    }
  }
}
