import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';

// ── Scan Line Painter ─────────────────────────────────────────────────────────

/// Draws 10 horizontal scan lines drifting downward — the PRISM ambient layer.
/// Use inside an AnimatedBuilder tied to a repeating AnimationController.
class ScanLinePainter extends CustomPainter {
  final double progress; // 0.0 → 1.0, from repeating controller
  final Color lineColor;
  final int lineCount;

  const ScanLinePainter({
    required this.progress,
    this.lineColor = PrismColors.scanLine,
    this.lineCount = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < lineCount; i++) {
      // Each line has a phase offset so they're staggered across the screen
      final phase = i / lineCount;
      double y = ((phase + progress) % 1.0) * size.height;

      // Fade: in at top 10%, full through 80%, out at bottom 10%
      final relY = y / size.height;
      double opacity;
      if (relY < 0.1) {
        opacity = relY / 0.1 * 0.12;
      } else if (relY > 0.9) {
        opacity = (1.0 - relY) / 0.1 * 0.12;
      } else {
        opacity = 0.12;
      }

      paint.color = lineColor.withOpacity(opacity);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(ScanLinePainter old) =>
      old.progress != progress || old.lineColor != lineColor;
}

// ── Ambient Particle Painter ─────────────────────────────────────────────────

class PrismParticle {
  double x; // 0–1 normalized
  double y; // 0–1 normalized
  final double speed;
  final Color color;
  final double size;
  final double phase;

  PrismParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
    required this.size,
    required this.phase,
  });
}

/// Generates and renders ambient floating particles on every screen.
/// progress: 0.0 → 1.0 from a repeating AnimationController.
class AmbientParticlePainter extends CustomPainter {
  final double progress;
  final List<PrismParticle> particles;

  AmbientParticlePainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = ((p.phase + progress * p.speed * 100) % 1.0);
      final x = p.x + math.sin(y * 8 + p.phase * 10) * 0.015;

      final paint = Paint()
        ..color = p.color.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(AmbientParticlePainter old) =>
      old.progress != progress;
}

/// Builds a consistent list of ambient particles — same count, deterministic.
List<PrismParticle> buildAmbientParticles({int count = 80}) {
  final rng = math.Random(42); // fixed seed gives stable layout
  final colors = [
    PrismColors.voltGreen,
    PrismColors.cyanBlitz,
    PrismColors.magentaFlare,
  ];
  return List.generate(count, (i) {
    return PrismParticle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      speed: 0.003 + rng.nextDouble() * 0.007,
      color: colors[rng.nextInt(colors.length)],
      size: 1.0 + rng.nextDouble() * 1.8,
      phase: rng.nextDouble(),
    );
  });
}

// ── Hexagon Border Painter ────────────────────────────────────────────────────

/// Paints a hexagonal border with optional glow.
class HexBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double glowRadius;

  const HexBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.glowRadius = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width < size.height ? size.width : size.height) / 2 * 0.93;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Glow
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + glowRadius
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius),
    );
    // Sharp border
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(HexBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.glowRadius != glowRadius;
}

// ── Radial Pulse Painter ──────────────────────────────────────────────────────

/// Expanding ring pulse — used on button taps.
class RadialPulsePainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;
  final Offset center;

  const RadialPulsePainter({
    required this.progress,
    required this.color,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final maxRadius = size.width * 0.8;
    final radius = maxRadius * progress;
    final opacity = (1.0 - progress) * 0.6;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(RadialPulsePainter old) =>
      old.progress != progress || old.color != color;
}

// ── Bracket Connector Painter ─────────────────────────────────────────────────

/// Draws angled bracket connector lines between match nodes.
class BracketConnectorPainter extends CustomPainter {
  final Color color;
  final bool isGlowing;

  const BracketConnectorPainter({
    required this.color,
    this.isGlowing = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midX = size.width / 2;

    final path = Path()
      ..moveTo(0, size.height * 0.25)
      ..lineTo(midX, size.height * 0.25)
      ..lineTo(midX, size.height * 0.75)
      ..lineTo(size.width, size.height * 0.75);

    if (isGlowing) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(BracketConnectorPainter old) =>
      old.color != color || old.isGlowing != isGlowing;
}

// ── Explosion Particle Painter ────────────────────────────────────────────────

/// 12 lines radiating from center — emitted on button taps.
class ExplosionParticlePainter extends CustomPainter {
  final double progress; // 0 → 1
  final Color color;

  const ExplosionParticlePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    const particleCount = 12;
    final center = Offset(size.width / 2, size.height / 2);
    final maxLen = size.width * 0.6;
    final opacity = (1.0 - progress) * 0.9;
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final startDist = maxLen * 0.1;
      final endDist = maxLen * progress;
      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * startDist,
            center.dy + math.sin(angle) * startDist),
        Offset(center.dx + math.cos(angle) * endDist,
            center.dy + math.sin(angle) * endDist),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ExplosionParticlePainter old) =>
      old.progress != progress || old.color != color;
}

// ── Isometric Ground Painter ──────────────────────────────────────────────────

/// Renders a pseudo-3D isometric football field for the GroundHologram widget.
class IsometricGroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color lineColor;
  final double scanProgress; // 0 → 1, scan line sweep
  final bool hasActivePlayers;

  const IsometricGroundPainter({
    required this.primaryColor,
    this.lineColor = PrismColors.ghostWhite,
    this.scanProgress = 0,
    this.hasActivePlayers = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Field base (isometric parallelogram) ─────────────────────────────────
    final fieldPath = Path()
      ..moveTo(w * 0.05, h * 0.5)
      ..lineTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.95, h * 0.5)
      ..lineTo(w * 0.5, h * 0.9)
      ..close();

    canvas.drawPath(
      fieldPath,
      Paint()
        ..color = primaryColor.withOpacity(0.08)
        ..style = PaintingStyle.fill,
    );

    // Glow border
    canvas.drawPath(
      fieldPath,
      Paint()
        ..color = primaryColor.withOpacity(hasActivePlayers ? 0.7 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = hasActivePlayers ? 2.0 : 1.0
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, hasActivePlayers ? 8 : 3),
    );

    // ── Center circle ─────────────────────────────────────────────────────────
    final centerX = w * 0.5;
    final centerY = h * 0.5;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: w * 0.25,
          height: h * 0.18),
      Paint()
        ..color = primaryColor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // ── Center line ───────────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(w * 0.05, h * 0.5),
      Offset(w * 0.95, h * 0.5),
      Paint()
        ..color = lineColor.withOpacity(0.15)
        ..strokeWidth = 0.8,
    );

    // ── Goal areas ────────────────────────────────────────────────────────────
    _drawGoalArea(canvas, Offset(w * 0.5, h * 0.2), w * 0.2, h * 0.12,
        primaryColor);
    _drawGoalArea(canvas, Offset(w * 0.5, h * 0.8), w * 0.2, h * 0.12,
        primaryColor);

    // ── Scan line sweep ───────────────────────────────────────────────────────
    if (scanProgress > 0 && scanProgress < 1) {
      final sweepY = h * 0.1 + (h * 0.8) * scanProgress;
      canvas.drawLine(
        Offset(0, sweepY),
        Offset(w, sweepY),
        Paint()
          ..color = primaryColor.withOpacity(0.35)
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  void _drawGoalArea(Canvas canvas, Offset center, double width, double height,
      Color color) {
    canvas.drawRect(
      Rect.fromCenter(center: center, width: width, height: height),
      Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(IsometricGroundPainter old) =>
      old.scanProgress != scanProgress ||
      old.primaryColor != primaryColor ||
      old.hasActivePlayers != hasActivePlayers;
}
