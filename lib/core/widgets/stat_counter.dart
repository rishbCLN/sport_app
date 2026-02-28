import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../utils/custom_painters.dart';

/// Animated number counter with hexagonal frame.
///
/// Counts from 0 to [value] over [duration] with easeOutCubic.
/// When [value] changes, smoothly counts up/down.
/// Used for: player counts, scores, timers, sweat scores.
class StatCounter extends StatefulWidget {
  final double value;
  final String label;
  final Color color;
  final String unit;
  final Duration duration;
  final double numberSize;

  const StatCounter({
    Key? key,
    required this.value,
    required this.label,
    this.color = PrismColors.voltGreen,
    this.unit = '',
    this.duration = const Duration(milliseconds: 600),
    this.numberSize = 32,
  }) : super(key: key);

  @override
  State<StatCounter> createState() => _StatCounterState();
}

class _StatCounterState extends State<StatCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  double _displayValue = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: widget.value),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        _displayValue = val;
        return AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, _) {
            return SizedBox(
              width: 80,
              height: 88,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hexagonal frame
                  CustomPaint(
                    size: const Size(80, 88),
                    painter: HexBorderPainter(
                      color: widget.color.withOpacity(
                          0.3 + _pulseCtrl.value * 0.3),
                      strokeWidth: 1.5,
                      glowRadius: 4 + _pulseCtrl.value * 4,
                    ),
                  ),
                  // Corner pulse dots
                  ..._cornerDots(widget.color, _pulseCtrl.value),
                  // Number + label
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: val.toInt().toString(),
                              style: PrismText.mono(
                                fontSize: widget.numberSize,
                                color: widget.color,
                              ),
                            ),
                            if (widget.unit.isNotEmpty)
                              TextSpan(
                                text: widget.unit,
                                style: PrismText.mono(
                                  fontSize: widget.numberSize * 0.55,
                                  color: widget.color.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.label.toUpperCase(),
                        style: PrismText.caption(
                            color: widget.color.withOpacity(0.7))
                            .copyWith(
                          letterSpacing: 2,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _cornerDots(Color color, double pulse) {
    const positions = [
      Alignment(-0.7, -0.88),
      Alignment(0.7, -0.88),
      Alignment(-0.7, 0.88),
      Alignment(0.7, 0.88),
    ];
    return positions.map((pos) {
      return Align(
        alignment: pos,
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: color.withOpacity(0.4 + pulse * 0.6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
