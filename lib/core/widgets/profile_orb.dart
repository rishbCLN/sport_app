import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../utils/custom_clippers.dart';
import '../utils/custom_painters.dart';

/// PRISM profile avatar widget.
///
/// Features:
/// * Hexagonal clip (never circular)
/// * Triple ring: avatar → role color ring → animated rotation glow
/// * Role tag badge at bottom-right corner
/// * Green live-dot at top-right when [isActive]
/// * Tap: scale bounce + radial pulse
class ProfileOrb extends StatefulWidget {
  final String? photoUrl;
  final String name;
  final String? roleTag;
  final Color ringColor;
  final bool isActive;
  final double size;
  final VoidCallback? onTap;

  const ProfileOrb({
    Key? key,
    this.photoUrl,
    required this.name,
    this.roleTag,
    this.ringColor = PrismColors.voltGreen,
    this.isActive = false,
    this.size = 56,
    this.onTap,
  }) : super(key: key);

  @override
  State<ProfileOrb> createState() => _ProfileOrbState();
}

class _ProfileOrbState extends State<ProfileOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotCtrl;
  double _tapScale = 1.0;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    setState(() => _tapScale = 0.88);
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => _tapScale = 1.08);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _tapScale = 1.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _tapScale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: SizedBox(
          width: s + 12,
          height: s + 12,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Outer rotating glow ring ─────────────────────────────────
              AnimatedBuilder(
                animation: _rotCtrl,
                builder: (_, __) => Transform.rotate(
                  angle: _rotCtrl.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(s + 12, s + 12),
                    painter: _ArcGlowPainter(
                      color: widget.ringColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              // ── Middle role color ring ────────────────────────────────────
              Container(
                width: s + 4,
                height: s + 4,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: CustomPaint(
                  painter: HexBorderPainter(
                    color: widget.ringColor,
                    strokeWidth: 2,
                    glowRadius: widget.isActive ? 8 : 3,
                  ),
                ),
              ),
              // ── Avatar (hexagonal clip) ───────────────────────────────────
              ClipPath(
                clipper: const HexagonClipper(),
                child: SizedBox(
                  width: s,
                  height: s,
                  child: widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                      ? Image.network(
                          widget.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              // ── Live dot (top-right) ──────────────────────────────────────
              if (widget.isActive)
                Positioned(
                  top: 2,
                  right: 2,
                  child: _PulsingDot(color: PrismColors.voltGreen),
                ),
              // ── Role badge (bottom-right) ─────────────────────────────────
              if (widget.roleTag != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 1),
                    color: widget.ringColor,
                    child: Text(
                      widget.roleTag!.toUpperCase(),
                      style: PrismText.tag(
                          color: PrismColors.voidBlack)
                          .copyWith(fontSize: 8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: PrismColors.concrete,
      alignment: Alignment.center,
      child: Text(
        widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
        style: PrismText.title(color: widget.ringColor)
            .copyWith(fontSize: widget.size * 0.38),
      ),
    );
  }
}

// ── Pulsing live dot ─────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3 + _ctrl.value * 0.5),
              blurRadius: 4 + _ctrl.value * 6,
              spreadRadius: _ctrl.value * 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Arc glow ring painter ─────────────────────────────────────────────────────

class _ArcGlowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _ArcGlowPainter({required this.color, this.strokeWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width < size.height ? size.width : size.height) / 2 - 2;

    // Draw a dashed arc that looks like a rotating ring
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth + 1);

    // Draw 3 arcs (dashes)
    for (int i = 0; i < 3; i++) {
      final startAngle = (i * 2 * math.pi / 3);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        math.pi / 2.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
