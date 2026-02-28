import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../utils/custom_clippers.dart';
import '../utils/custom_painters.dart';

/// Variant of VoltButton
enum VoltButtonVariant { primary, danger, ghost }

/// PRISM primary CTA button.
///
/// 3-stage tap choreography:
/// 1. Anticipation — scale to 0.92 in 80ms
/// 2. Action — explosion particles emit + scale back with easeOutBack overshoot
/// 3. Settle — returns to 1.0
/// Haptic feedback on every tap.
class VoltButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final VoltButtonVariant variant;
  final Color? accentColor;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double height;

  const VoltButton({
    Key? key,
    required this.label,
    this.onTap,
    this.variant = VoltButtonVariant.primary,
    this.accentColor,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height = 52,
  }) : super(key: key);

  @override
  State<VoltButton> createState() => _VoltButtonState();
}

class _VoltButtonState extends State<VoltButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _particle;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);

    _scale = TweenSequence<double>([
      // Anticipation — shrinks 8% in 80ms
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.92)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      // Action — overshoots back in 200ms
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      // Settle — back to 1.0 in 150ms
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20,
      ),
    ]).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );

    _particle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.25, 0.75, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null || widget.isLoading) return;
    HapticFeedback.lightImpact();
    await _ctrl.animateTo(1.0,
        duration: const Duration(milliseconds: 430), curve: Curves.linear);
    _ctrl.reset();
    widget.onTap?.call();
  }

  Color get _accent =>
      widget.accentColor ??
      (widget.variant == VoltButtonVariant.danger
          ? PrismColors.redAlert
          : PrismColors.voltGreen);

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null || widget.isLoading;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Transform.scale(
            scale: _scale.value,
            child: SizedBox(
              width: widget.fullWidth ? double.infinity : null,
              height: widget.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Button body
                  ClipPath(
                    clipper: const ParallelogramClipper(skew: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _buttonBackground(isDisabled),
                        border: Border.all(
                          color: isDisabled
                              ? PrismColors.dimGray
                              : _accent.withOpacity(0.9),
                          width: 1,
                        ),
                        boxShadow: isDisabled
                            ? null
                            : [
                                BoxShadow(
                                  color: _accent.withOpacity(0.35),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                              ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading) ...[
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: widget.variant ==
                                        VoltButtonVariant.ghost
                                    ? _accent
                                    : PrismColors.voidBlack,
                              ),
                            ),
                          ] else ...[
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: 18,
                                color: _labelColor(isDisabled),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: PrismText.button(
                                  color: _labelColor(isDisabled)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Particle explosion overlay
                  if (_particle.value > 0 && _particle.value < 1)
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: ExplosionParticlePainter(
                              progress: _particle.value,
                              color: _accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _buttonBackground(bool disabled) {
    if (disabled) return PrismColors.concrete;
    switch (widget.variant) {
      case VoltButtonVariant.primary:
      case VoltButtonVariant.danger:
        return _accent;
      case VoltButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _labelColor(bool disabled) {
    if (disabled) return PrismColors.dimGray;
    switch (widget.variant) {
      case VoltButtonVariant.primary:
      case VoltButtonVariant.danger:
        return PrismColors.voidBlack;
      case VoltButtonVariant.ghost:
        return _accent;
    }
  }
}
