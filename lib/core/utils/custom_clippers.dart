import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Parallelogram (primary container shape) ───────────────────────────────────

/// A parallelogram skewed 8px — used for cards, buttons, primary containers.
/// No rounded corners. The signature PRISM shape.
class ParallelogramClipper extends CustomClipper<Path> {
  final double skew;
  const ParallelogramClipper({this.skew = 8});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(skew, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - skew, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(ParallelogramClipper old) => old.skew != skew;
}

// ── Chamfered Rectangle (45° corners) ────────────────────────────────────────

/// Cuts 45° corner clips — chamfered rectangle for banners & hero cards.
class ChamferedClipper extends CustomClipper<Path> {
  final double chamfer;
  const ChamferedClipper({this.chamfer = 12});

  @override
  Path getClip(Size size) {
    final c = chamfer;
    return Path()
      ..moveTo(c, 0)
      ..lineTo(size.width - c, 0)
      ..lineTo(size.width, c)
      ..lineTo(size.width, size.height - c)
      ..lineTo(size.width - c, size.height)
      ..lineTo(c, size.height)
      ..lineTo(0, size.height - c)
      ..lineTo(0, c)
      ..close();
  }

  @override
  bool shouldReclip(ChamferedClipper old) => old.chamfer != chamfer;
}

// ── Hexagon ───────────────────────────────────────────────────────────────────

/// Hexagonal clip used for profile avatars and stat counter frames.
class HexagonClipper extends CustomClipper<Path> {
  const HexagonClipper();

  @override
  Path getClip(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width < size.height ? size.width : size.height) / 2 * 0.95;

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
    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Arrow Tab ─────────────────────────────────────────────────────────────────

/// A tab/chip that has a right-pointing arrow tip — for filter chips.
class ArrowTabClipper extends CustomClipper<Path> {
  final double arrowSize;
  const ArrowTabClipper({this.arrowSize = 8});

  @override
  Path getClip(Size size) {
    final a = arrowSize;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - a, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - a, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(ArrowTabClipper old) => old.arrowSize != arrowSize;
}

// ── Top-Chamfered Sheet ───────────────────────────────────────────────────────

/// Chamfers only the top-left and top-right corners — for bottom drawers.
class TopChamferedClipper extends CustomClipper<Path> {
  final double chamfer;
  const TopChamferedClipper({this.chamfer = 16});

  @override
  Path getClip(Size size) {
    final c = chamfer;
    return Path()
      ..moveTo(c, 0)
      ..lineTo(size.width - c, 0)
      ..lineTo(size.width, c)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, c)
      ..close();
  }

  @override
  bool shouldReclip(TopChamferedClipper old) => old.chamfer != chamfer;
}

