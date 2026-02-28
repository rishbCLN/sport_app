import 'package:flutter/material.dart';
import '../utils/custom_painters.dart';

/// Full-screen ambient particle field — the PRISM app signature.
///
/// Renders 80 slowly drifting colored particles behind all content.
/// Uses a repeating 60s AnimationController; wrapped in RepaintBoundary
/// to isolate repaints from the rest of the UI.
class AmbientParticles extends StatefulWidget {
  final Widget child;

  const AmbientParticles({Key? key, required this.child}) : super(key: key);

  @override
  State<AmbientParticles> createState() => _AmbientParticlesState();
}

class _AmbientParticlesState extends State<AmbientParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<PrismParticle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _particles = buildAmbientParticles(count: 80);
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
        // Particle layer — fully isolated repaint
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(
                painter: AmbientParticlePainter(
                  progress: _ctrl.value,
                  particles: _particles,
                ),
              ),
            ),
          ),
        ),
        // Application content sits above
        widget.child,
      ],
    );
  }
}
