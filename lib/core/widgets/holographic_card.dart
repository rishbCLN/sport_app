import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/custom_clippers.dart';
import '../utils/custom_painters.dart';

/// PRISM signature card widget.
///
/// Features:
/// * Parallelogram clip (chamfered edges, no rounded corners)
/// * 3-layer depth: dark base + gradient border + inner content
/// * Animated scan line sweeping top-to-bottom on a 2s loop
/// * On tap: glow intensifies over 200ms
/// * Optional sport-specific accent color
class HolographicCard extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double skew;
  final bool showScanLine;
  final bool isLive;
  final double? height;
  final Color? backgroundColor;

  const HolographicCard({
    Key? key,
    required this.child,
    this.accentColor = PrismColors.voltGreen,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.skew = 8,
    this.showScanLine = true,
    this.isLive = false,
    this.height,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<HolographicCard> createState() => _HolographicCardState();
}

class _HolographicCardState extends State<HolographicCard>
    with TickerProviderStateMixin {
  late final AnimationController _scanCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _tapCtrl;
  // Separate pulsing controller for isLive border glow
  late final AnimationController _liveCtrl;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isLive ? 1.0 : 0.0,
    );

    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _liveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isLive) _liveCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(HolographicCard old) {
    super.didUpdateWidget(old);
    if (widget.isLive != old.isLive) {
      if (widget.isLive) {
        _glowCtrl.forward();
        _liveCtrl.repeat(reverse: true);
      } else {
        _glowCtrl.reverse();
        _liveCtrl.stop();
        _liveCtrl.animateTo(0.0,
            duration: const Duration(milliseconds: 300));
      }
    }
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _glowCtrl.dispose();
    _tapCtrl.dispose();
    _liveCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _pressed = true);
    _glowCtrl.forward();
    _tapCtrl.forward();
  }

  void _onTapUp(_) {
    setState(() => _pressed = false);
    if (!widget.isLive) _glowCtrl.reverse();
    _tapCtrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    if (!widget.isLive) _glowCtrl.reverse();
    _tapCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scanCtrl, _glowCtrl, _tapCtrl, _liveCtrl]),
        builder: (context, _) {
          final glowIntensity = _glowCtrl.value;
          final tapScale = 1.0 - _tapCtrl.value * 0.04;

          return Transform.scale(
            scale: tapScale,
            child: ClipPath(
              clipper: ParallelogramClipper(skew: widget.skew),
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? PrismColors.pitch,
                  border: Border.all(
                    color: widget.accentColor
                        .withOpacity(0.15 + glowIntensity * 0.45),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor
                          .withOpacity(0.05 + glowIntensity * 0.25),
                      blurRadius: 16 + glowIntensity * 24,
                      spreadRadius: glowIntensity * 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.accentColor.withOpacity(0.04),
                              Colors.transparent,
                              widget.accentColor.withOpacity(0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Scan line
                    if (widget.showScanLine)
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: ScanLinePainter(
                              progress: _scanCtrl.value,
                              lineColor: widget.accentColor,
                              lineCount: 6,
                            ),
                          ),
                        ),
                      ),
                    // Live indicator border — pulses via _liveCtrl
                    if (widget.isLive)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: PrismColors.redAlert
                                  .withOpacity(0.3 + _liveCtrl.value * 0.6),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    // Content
                    Padding(
                      padding: widget.padding,
                      child: widget.child,
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
