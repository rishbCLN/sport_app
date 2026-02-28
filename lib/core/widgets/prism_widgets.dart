import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../utils/custom_clippers.dart';

/// PRISM filter/tab chip with arrow shape.
/// Selected state: full accent background + glow.
class PrismFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const PrismFilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.accentColor = PrismColors.voltGreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: ClipPath(
          clipper: const ArrowTabClipper(arrowSize: 6),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withOpacity(0.15)
                  : PrismColors.concrete,
              border: Border.all(
                color:
                    isSelected ? accentColor : PrismColors.dimGray,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.25),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label.toUpperCase(),
              style: PrismText.tag(
                color: isSelected ? accentColor : PrismColors.steelGray,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Live badge — pulsing red dot with "LIVE" text.
class LiveBadge extends StatefulWidget {
  const LiveBadge({Key? key}) : super(key: key);

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: PrismColors.redAlert.withOpacity(0.15),
          border: Border.all(
            color: PrismColors.redAlert
                .withOpacity(0.4 + _ctrl.value * 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: PrismColors.redAlert,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PrismColors.redAlert
                        .withOpacity(0.4 + _ctrl.value * 0.5),
                    blurRadius: 4 + _ctrl.value * 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'LIVE',
              style: PrismText.tag(color: PrismColors.redAlert)
                  .copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sport icon chip — shows sport-specific icon with accent color.
class SportIconBadge extends StatelessWidget {
  final String sport;

  const SportIconBadge({Key? key, required this.sport}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = PrismColors.sportAccent(sport);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        border: Border.all(color: accent.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_sportEmoji(sport), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            sport.toUpperCase(),
            style: PrismText.tag(color: accent).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _sportEmoji(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return '⚽';
      case 'badminton':
        return '🏸';
      case 'cricket':
        return '🏏';
      default:
        return '🏆';
    }
  }
}

/// Countdown progress bar — shrinks from full to 0 as time elapses.
class CountdownBar extends StatelessWidget {
  final Duration remaining;
  final Duration total;
  final Color? color;

  const CountdownBar({
    Key? key,
    required this.remaining,
    required this.total,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (remaining.inSeconds / total.inSeconds).clamp(0.0, 1.0);
    final isLow = progress < 0.17; // < 5min for 30min timer
    final accentColor = isLow ? PrismColors.redAlert : (color ?? PrismColors.voltGreen);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(remaining),
              style: PrismText.mono(
                fontSize: 13,
                color: accentColor,
              ),
            ),
            Text(
              'LEFT',
              style: PrismText.label(color: accentColor).copyWith(fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            // Track
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: PrismColors.concrete,
              ),
            ),
            // Fill
            AnimatedFractionallySizedBox(
              widthFactor: progress,
              duration: const Duration(seconds: 1),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
