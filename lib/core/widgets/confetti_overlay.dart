import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Full-screen confetti celebration — triggered on tournament wins / match end.
///
/// Uses a CustomPainter with physics-based particles falling from the top.
/// Call [ConfettiOverlay.show(context, winnerName)] as a static helper.
class ConfettiOverlay extends StatefulWidget {
  final String? winnerName;
  final Color accentColor;

  const ConfettiOverlay({
    Key? key,
    this.winnerName,
    this.accentColor = PrismColors.voltGreen,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    String? winnerName,
    Color accentColor = PrismColors.voltGreen,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => ConfettiOverlay(
          winnerName: winnerName,
          accentColor: accentColor,
        ),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward().then((_) => Navigator.of(context).pop());

    final rng = math.Random();
    final colors = [
      PrismColors.voltGreen,
      PrismColors.cyanBlitz,
      PrismColors.magentaFlare,
      PrismColors.amberShock,
    ];
    _pieces = List.generate(250, (_) => _ConfettiPiece(
      x: rng.nextDouble(),
      speed: 0.15 + rng.nextDouble() * 0.35,
      size: 4 + rng.nextDouble() * 6,
      color: colors[rng.nextInt(colors.length)],
      rotation: rng.nextDouble() * 2 * math.pi,
      rotSpeed: (rng.nextDouble() - 0.5) * 6,
      drift: (rng.nextDouble() - 0.5) * 0.3,
      isTriangle: rng.nextBool(),
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // White flash
          AnimatedBuilder(
            animation: CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0, 0.04),
            ),
            builder: (_, __) => Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(
                    (1.0 - _ctrl.value / 0.04).clamp(0.0, 1.0) * 0.6),
              ),
            ),
          ),
          // Confetti
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: _ConfettiPainter(
                    progress: _ctrl.value,
                    pieces: _pieces,
                  ),
                ),
              ),
            ),
          ),
          // Winner announcement
          if (widget.winnerName != null)
            Center(
              child: AnimatedBuilder(
                animation: CurvedAnimation(
                  parent: _ctrl,
                  curve: const Interval(0.04, 0.25, curve: Curves.easeOutBack),
                ),
                builder: (_, __) {
                  final t = CurvedAnimation(
                    parent: _ctrl,
                    curve:
                        const Interval(0.04, 0.25, curve: Curves.easeOutBack),
                  ).value;
                  return Transform.scale(
                    scale: t,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🏆',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          color: PrismColors.pitch,
                          child: Text(
                            widget.winnerName!.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: widget.accentColor,
                              shadows: [
                                Shadow(
                                  color:
                                      widget.accentColor.withOpacity(0.8),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'CHAMPIONS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: PrismColors.steelGray,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double rotation;
  final double rotSpeed;
  final double drift;
  final bool isTriangle;

  const _ConfettiPiece({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotSpeed,
    required this.drift,
    required this.isTriangle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPiece> pieces;

  const _ConfettiPainter({required this.progress, required this.pieces});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final y = p.speed * progress * size.height * 1.5;
      if (y > size.height + 20) continue;

      final x = p.x * size.width + math.sin(y * 0.02 + p.drift) * 30;
      final angle = p.rotation + p.rotSpeed * progress * 6;

      // Fade out in last second
      final opacity = progress > 0.75
          ? (1.0 - (progress - 0.75) / 0.25).clamp(0.0, 1.0)
          : 1.0;

      final paint = Paint()..color = p.color.withOpacity(opacity * 0.9);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      if (p.isTriangle) {
        final path = Path()
          ..moveTo(0, -p.size)
          ..lineTo(p.size * 0.866, p.size * 0.5)
          ..lineTo(-p.size * 0.866, p.size * 0.5)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.5),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
