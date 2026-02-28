import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/custom_painters.dart';

/// Persistent neon scan line ambient layer.
///
/// 8–12 horizontal lines drifting slowly downward on every screen.
/// Sits behind all content. Never stops.
class NeonScanLine extends StatefulWidget {
  final Widget child;
  final Color lineColor;

  const NeonScanLine({
    Key? key,
    required this.child,
    this.lineColor = PrismColors.scanLine,
  }) : super(key: key);

  @override
  State<NeonScanLine> createState() => _NeonScanLineState();
}

class _NeonScanLineState extends State<NeonScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(
                painter: ScanLinePainter(
                  progress: _ctrl.value,
                  lineColor: widget.lineColor,
                  lineCount: 10,
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

/// Complete PRISM screen wrapper: abyss background + ambient particles + neon lines.
class PrismScaffold extends StatelessWidget {
  final Widget child;
  final bool showScanLines;

  const PrismScaffold({
    Key? key,
    required this.child,
    this.showScanLines = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PrismColors.abyss,
      child: showScanLines ? NeonScanLine(child: child) : child,
    );
  }
}
