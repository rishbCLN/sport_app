import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../utils/custom_clippers.dart';
import '../utils/custom_painters.dart';

/// 3D isometric ground card — the visual centerpiece of the football screen.
///
/// Shows an isometric football field with:
/// * Animated scan line sweep (every 3s)
/// * Player count badge
/// * Pulsing glow border when players are active
/// * Tap to open team request drawer
class GroundHologram extends StatefulWidget {
  final String groundName;
  final Color accentColor;
  final int activePlayers;
  final int maxPlayers;
  final int teamCount;
  final VoidCallback? onTap;
  final bool isUserOnGround;

  const GroundHologram({
    Key? key,
    required this.groundName,
    this.accentColor = PrismColors.voltGreen,
    this.activePlayers = 0,
    this.maxPlayers = 6,
    this.teamCount = 0,
    this.onTap,
    this.isUserOnGround = false,
  }) : super(key: key);

  @override
  State<GroundHologram> createState() => _GroundHologramState();
}

class _GroundHologramState extends State<GroundHologram>
    with TickerProviderStateMixin {
  late final AnimationController _scanCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _tapCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _glowCtrl.dispose();
    _tapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPlayers = widget.activePlayers > 0;
    final accent = widget.accentColor;

    return GestureDetector(
      onTapDown: (_) => _tapCtrl.forward(),
      onTapUp: (_) {
        _tapCtrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _tapCtrl.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scanCtrl, _glowCtrl, _tapCtrl]),
        builder: (context, _) {
          final glow = _glowCtrl.value;
          final tapScale = 1.0 - _tapCtrl.value * 0.03;

          return Transform.scale(
            scale: tapScale,
            child: ClipPath(
              clipper: const ChamferedClipper(chamfer: 10),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: PrismColors.pitch,
                  border: Border.all(
                    color: hasPlayers
                        ? accent.withOpacity(0.3 + glow * 0.5)
                        : accent.withOpacity(0.15),
                    width: hasPlayers ? 1.5 : 1,
                  ),
                  boxShadow: hasPlayers
                      ? [
                          BoxShadow(
                            color:
                                accent.withOpacity(0.1 + glow * 0.2),
                            blurRadius: 16 + glow * 16,
                            spreadRadius: glow * 2,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    // Isometric field
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: IsometricGroundPainter(
                            primaryColor: accent,
                            scanProgress: _scanCtrl.value,
                            hasActivePlayers: hasPlayers,
                          ),
                        ),
                      ),
                    ),
                    // Player orbs (simplified as dots in formation)
                    if (hasPlayers)
                      Positioned.fill(
                        child: _PlayerOrbs(
                          count: widget.activePlayers,
                          color: accent,
                          glowPulse: glow,
                        ),
                      ),
                    // Ground name + status
                    Positioned(
                      top: 8,
                      left: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.groundName.toUpperCase(),
                            style: PrismText.label(color: accent),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasPlayers
                                ? '${widget.activePlayers}/${widget.maxPlayers} ACTIVE'
                                : 'NO TEAMS',
                            style: PrismText.caption(
                              color: hasPlayers
                                  ? PrismColors.ghostWhite
                                  : PrismColors.dimGray,
                            ).copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    // Team count badge
                    if (widget.teamCount > 0)
                      Positioned(
                        top: 8,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          color: accent.withOpacity(0.15),
                          child: Text(
                            '${widget.teamCount} TEAM${widget.teamCount > 1 ? 'S' : ''}',
                            style: PrismText.tag(color: accent)
                                .copyWith(fontSize: 10),
                          ),
                        ),
                      ),
                    // User-on-ground indicator
                    if (widget.isUserOnGround)
                      Positioned(
                        bottom: 8,
                        right: 12,
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withOpacity(0.8),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'YOU\'RE HERE',
                              style: PrismText.tag(color: accent)
                                  .copyWith(fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    // Tap hint
                    Positioned(
                      bottom: 8,
                      left: 12,
                      child: Text(
                        'TAP TO JOIN →',
                        style: PrismText.caption(
                                color: accent.withOpacity(0.5))
                            .copyWith(fontSize: 9, letterSpacing: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Player orb formation display ─────────────────────────────────────────────

class _PlayerOrbs extends StatelessWidget {
  final int count;
  final Color color;
  final double glowPulse;

  const _PlayerOrbs({
    required this.count,
    required this.color,
    required this.glowPulse,
  });

  // Football formation positions (normalized 0–1)
  static const _positions = [
    Offset(0.5, 0.8),  // Striker
    Offset(0.3, 0.6),  // Left mid
    Offset(0.7, 0.6),  // Right mid
    Offset(0.5, 0.55), // Central mid
    Offset(0.25, 0.42), // Left back
    Offset(0.75, 0.42), // Right back
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      return Stack(
        children: List.generate(
          count.clamp(0, _positions.length),
          (i) {
            final pos = _positions[i];
            return Positioned(
              left: pos.dx * w - 6,
              top: pos.dy * h - 6,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3 + glowPulse * 0.5),
                      blurRadius: 6 + glowPulse * 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
