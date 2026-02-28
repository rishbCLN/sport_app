import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// PRISM Typography System — "Stadium Display"
///
/// Display/Hero : Orbitron  (futuristic, geometric)
/// Subheadings  : Rajdhani  (condensed, bold, industrial)
/// Body/Labels  : Inter     (clean, neutral)
/// Data/Mono    : JetBrains Mono (technical precision)
class PrismText {
  PrismText._();

  // ── Hero — screen headers, tournament names ────────────────────────────────
  static TextStyle hero({Color color = PrismColors.ghostWhite}) =>
      GoogleFonts.orbitron(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 2.0,
        height: 0.95,
        shadows: [
          Shadow(
            color: PrismColors.voltGreen.withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      );

  // ── Display — section hero numbers ────────────────────────────────────────
  static TextStyle display({Color color = PrismColors.ghostWhite}) =>
      GoogleFonts.orbitron(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 1.5,
        shadows: [
          Shadow(
            color: color.withOpacity(0.4),
            blurRadius: 16,
          ),
        ],
      );

  // ── Label — section headers in all-caps ───────────────────────────────────
  static TextStyle label({Color color = PrismColors.voltGreen}) =>
      GoogleFonts.rajdhani(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 3.0,
      );

  // ── Title — card titles, team names ───────────────────────────────────────
  static TextStyle title({Color color = PrismColors.ghostWhite}) =>
      GoogleFonts.rajdhani(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.1,
      );

  // ── Subtitle — secondary card text ────────────────────────────────────────
  static TextStyle subtitle({Color color = PrismColors.steelGray}) =>
      GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  // ── Body — descriptions, rules ────────────────────────────────────────────
  static TextStyle body({Color color = PrismColors.steelGray}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.6,
      );

  // ── Caption — tiny helper text ────────────────────────────────────────────
  static TextStyle caption({Color color = PrismColors.dimGray}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 0.5,
      );

  // ── Mono — scores, timers, stats ──────────────────────────────────────────
  static TextStyle mono({
    double fontSize = 18,
    Color color = PrismColors.ghostWhite,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.5,
      );

  // ── Button — CTA text ─────────────────────────────────────────────────────
  static TextStyle button({Color color = PrismColors.voidBlack}) =>
      GoogleFonts.rajdhani(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 2.0,
      );

  // ── Tag chip text ─────────────────────────────────────────────────────────
  static TextStyle tag({Color color = PrismColors.voltGreen}) =>
      GoogleFonts.rajdhani(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.5,
      );
}
