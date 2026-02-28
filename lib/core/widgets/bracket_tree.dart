import 'package:flutter/material.dart';
import '../../models/match.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../utils/custom_clippers.dart';
import '../utils/custom_painters.dart';

/// Tournament bracket visualizer.
///
/// Renders a horizontally scrollable bracket structure.
/// Each match is a node with two team slots connected by glowing lines.
/// Completed matches show scores; live matches pulsate.
class BracketTree extends StatelessWidget {
  final List<TournamentMatch> matches;
  final Color accentColor;
  final void Function(TournamentMatch match)? onMatchTap;

  const BracketTree({
    Key? key,
    required this.matches,
    this.accentColor = PrismColors.voltGreen,
    this.onMatchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group matches by round
    final Map<String, List<TournamentMatch>> rounds = {};
    for (final m in matches) {
      final r = m.round;
      rounds[r] = [...(rounds[r] ?? []), m];
    }
    // Sort rounds alphanumerically (Round 1, Round 2 ... Final)
    final sortedRounds = rounds.keys.toList()..sort();

    if (sortedRounds.isEmpty) {
      return Center(
        child: Text(
          'NO MATCHES SCHEDULED',
          style: PrismText.label(color: accentColor),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: sortedRounds.asMap().entries.map((entry) {
          final roundIdx = entry.key;
          final roundKey = entry.value;
          final roundMatches = rounds[roundKey]!;

          return Row(
            children: [
              // Round column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      roundKey.toUpperCase(),
                      style: PrismText.label(
                              color: accentColor.withOpacity(0.7))
                          .copyWith(fontSize: 10),
                    ),
                  ),
                  ...roundMatches.map((match) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _MatchNode(
                        match: match,
                        accentColor: accentColor,
                        onTap: onMatchTap != null
                            ? () => onMatchTap!(match)
                            : null,
                      ),
                    );
                  }),
                ],
              ),
              // Connector lines (not after last round)
              if (roundIdx < sortedRounds.length - 1)
                SizedBox(
                  width: 40,
                  height: roundMatches.length * 100.0,
                  child: CustomPaint(
                    painter: BracketConnectorPainter(
                      color: accentColor.withOpacity(0.4),
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Match node ───────────────────────────────────────────────────────────────

class _MatchNode extends StatefulWidget {
  final TournamentMatch match;
  final Color accentColor;
  final VoidCallback? onTap;

  const _MatchNode({
    required this.match,
    required this.accentColor,
    this.onTap,
  });

  @override
  State<_MatchNode> createState() => _MatchNodeState();
}

class _MatchNodeState extends State<_MatchNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.match.status == 'live') {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.match.status == 'live';
    final isCompleted = widget.match.status == 'completed';
    final accent = isLive ? PrismColors.redAlert : widget.accentColor;

    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, _) {
        return GestureDetector(
          onTap: widget.onTap,
          child: ClipPath(
            clipper: const ChamferedClipper(chamfer: 6),
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: PrismColors.pitch,
                border: Border.all(
                  color: accent.withOpacity(
                      isLive ? 0.4 + _pulseCtrl.value * 0.5 : 0.3),
                  width: isLive ? 1.5 : 1,
                ),
                boxShadow: isLive
                    ? [
                        BoxShadow(
                          color: accent
                              .withOpacity(0.1 + _pulseCtrl.value * 0.2),
                          blurRadius: 12 + _pulseCtrl.value * 8,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LIVE badge
                  if (isLive)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      color: PrismColors.redAlert
                          .withOpacity(0.15 + _pulseCtrl.value * 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: PrismColors.redAlert,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            'LIVE',
                            style: PrismText.tag(
                                    color: PrismColors.redAlert)
                                .copyWith(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  // Team A
                  _TeamSlot(
                    teamName: widget.match.team1Name,
                    score: widget.match.team1Score,
                    isWinner: isCompleted &&
                        (widget.match.team1Score ?? 0) >
                            (widget.match.team2Score ?? 0),
                    accentColor: widget.accentColor,
                  ),
                  // Divider
                  Container(
                    height: 1,
                    color: PrismColors.concrete,
                  ),
                  // Team B
                  _TeamSlot(
                    teamName: widget.match.team2Name,
                    score: widget.match.team2Score,
                    isWinner: isCompleted &&
                        (widget.match.team2Score ?? 0) >
                            (widget.match.team1Score ?? 0),
                    accentColor: widget.accentColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TeamSlot extends StatelessWidget {
  final String teamName;
  final int? score;
  final bool isWinner;
  final Color accentColor;

  const _TeamSlot({
    required this.teamName,
    this.score,
    this.isWinner = false,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: isWinner
          ? BoxDecoration(
              color: accentColor.withOpacity(0.08),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              teamName,
              style: PrismText.subtitle(
                color: isWinner
                    ? accentColor
                    : PrismColors.ghostWhite,
              ).copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (score != null)
            Text(
              score.toString(),
              style: PrismText.mono(
                fontSize: 16,
                color: isWinner
                    ? accentColor
                    : PrismColors.steelGray,
              ),
            ),
        ],
      ),
    );
  }
}
