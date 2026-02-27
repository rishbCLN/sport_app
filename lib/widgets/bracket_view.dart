import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/match.dart';
import '../models/tournament.dart';

Color _matchStatusColor(String status) {
  switch (status) {
    case 'live':
      return const Color(0xFFF44336);
    case 'completed':
      return const Color(0xFF4CAF50);
    case 'postponed':
      return const Color(0xFFFF9800);
    default:
      return const Color(0xFF9E9E9E);
  }
}

/// Visual bracket display for single-elimination tournaments.
/// For round-robin, falls back to a schedule list.
class BracketView extends StatelessWidget {
  final Tournament tournament;
  final bool isAdmin;
  final void Function(TournamentMatch match)? onMatchTap;

  const BracketView({
    Key? key,
    required this.tournament,
    this.isAdmin = false,
    this.onMatchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tournament.format == 'Round Robin') {
      return _RoundRobinView(tournament: tournament, onMatchTap: onMatchTap);
    }
    return _EliminationBracket(
      tournament: tournament,
      isAdmin: isAdmin,
      onMatchTap: onMatchTap,
    );
  }
}

// ─── Elimination Bracket ──────────────────────────────────────────────────────

class _EliminationBracket extends StatelessWidget {
  final Tournament tournament;
  final bool isAdmin;
  final void Function(TournamentMatch match)? onMatchTap;

  const _EliminationBracket({
    required this.tournament,
    required this.isAdmin,
    this.onMatchTap,
  });

  @override
  Widget build(BuildContext context) {
    // Group matches by round label order
    final rounds = _groupByRound(tournament.matchSchedule);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rounds.entries.map((entry) {
          return _RoundColumn(
            roundName: entry.key,
            matches: entry.value,
            isAdmin: isAdmin,
            onMatchTap: onMatchTap,
          );
        }).toList(),
      ),
    );
  }

  Map<String, List<TournamentMatch>> _groupByRound(
      List<TournamentMatch> matches) {
    // Define display order for common round names
    const order = [
      'Group', 'Round of 32', 'Round of 16', 'Quarter Final',
      'Semi Final', 'Third Place', 'Final',
    ];

    final map = <String, List<TournamentMatch>>{};
    for (final m in matches) {
      map.putIfAbsent(m.round, () => []).add(m);
    }
    // Sort rounds by known order
    final sorted = <String, List<TournamentMatch>>{};
    for (final key in order) {
      if (map.containsKey(key)) sorted[key] = map[key]!;
    }
    // Add any unknown rounds at end
    for (final key in map.keys) {
      if (!sorted.containsKey(key)) sorted[key] = map[key]!;
    }
    return sorted;
  }
}

class _RoundColumn extends StatelessWidget {
  final String roundName;
  final List<TournamentMatch> matches;
  final bool isAdmin;
  final void Function(TournamentMatch match)? onMatchTap;

  const _RoundColumn({
    required this.roundName,
    required this.matches,
    required this.isAdmin,
    this.onMatchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 195,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Round header
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF7CFC00).withOpacity(0.3)),
            ),
            child: Text(
              roundName.toUpperCase(),
              style: GoogleFonts.audiowide(
                color: const Color(0xFF7CFC00),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...matches.map((m) => _MatchCard(
                match: m,
                onTap: onMatchTap != null ? () => onMatchTap!(m) : null,
              )),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final TournamentMatch match;
  final VoidCallback? onTap;

  const _MatchCard({required this.match, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _matchStatusColor(match.status);
    final winner = match.winnerId;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: match.isLive()
                ? Colors.red.withOpacity(0.6)
                : const Color(0xFF2A2A2A),
            width: match.isLive() ? 1.5 : 1,
          ),
          boxShadow: match.isLive()
              ? [BoxShadow(color: Colors.red.withOpacity(0.15), blurRadius: 12)]
              : [],
        ),
        child: Column(
          children: [
            // Match number header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'M${match.matchNumber}',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                  ),
                ],
              ),
            ),
            // Team 1
            _teamRow(
              name: match.team1Name,
              score: match.team1Score,
              isWinner: winner == match.team1Id && winner != null,
              isTbd: match.team1Id == 'TBD',
            ),
            Divider(height: 1, color: Colors.white10),
            // Team 2
            _teamRow(
              name: match.team2Name,
              score: match.team2Score,
              isWinner: winner == match.team2Id && winner != null,
              isTbd: match.team2Id == 'TBD',
            ),
            // Time footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 10, color: Colors.white38),
                  const SizedBox(width: 3),
                  Text(
                    _fmtTime(match.scheduledTime),
                    style: GoogleFonts.rajdhani(
                      color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    match.ground.replaceFirst(' Ground', ''),
                    style: GoogleFonts.rajdhani(
                      color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamRow({
    required String name,
    int? score,
    bool isWinner = false,
    bool isTbd = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.rajdhani(
                color: isTbd
                    ? Colors.white30
                    : isWinner
                        ? const Color(0xFF7CFC00)
                        : Colors.white,
                fontSize: 13,
                fontWeight: isWinner ? FontWeight.w800 : FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (score != null)
            Container(
              width: 28,
              alignment: Alignment.center,
              child: Text(
                '$score',
                style: GoogleFonts.audiowide(
                  color: isWinner ? const Color(0xFF7CFC00) : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else if (isWinner)
            const Icon(Icons.check_circle, size: 14, color: Color(0xFF7CFC00)),
        ],
      ),
    );
  }

  String _fmtTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day}/${d.month} $h:$m $ampm';
  }
}

// ─── Round Robin View ─────────────────────────────────────────────────────────

class _RoundRobinView extends StatelessWidget {
  final Tournament tournament;
  final void Function(TournamentMatch match)? onMatchTap;

  const _RoundRobinView({required this.tournament, this.onMatchTap});

  @override
  Widget build(BuildContext context) {
    final matches = tournament.matchSchedule
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Schedule not generated yet',
            style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, i) {
        final m = matches[i];
        return _MatchCard(
          match: m,
          onTap: onMatchTap != null ? () => onMatchTap!(m) : null,
        );
      },
    );
  }
}
