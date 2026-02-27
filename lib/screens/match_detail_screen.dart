import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/match.dart';

/// Bottom sheet / full screen showing details of a single match.
class MatchDetailSheet extends StatefulWidget {
  final TournamentMatch match;

  const MatchDetailSheet({Key? key, required this.match}) : super(key: key);

  static void show(BuildContext context, TournamentMatch match) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MatchDetailSheet(match: match),
    );
  }

  @override
  State<MatchDetailSheet> createState() => _MatchDetailSheetState();
}

class _MatchDetailSheetState extends State<MatchDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _liveCtrl;
  late Animation<double> _livePulse;
  Timer? _liveTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _liveCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _livePulse = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _liveCtrl, curve: Curves.easeInOut));

    if (widget.match.isLive() && widget.match.actualStartTime != null) {
      _elapsedSeconds =
          DateTime.now().difference(widget.match.actualStartTime!).inSeconds;
      _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsedSeconds++);
      });
    }
  }

  @override
  void dispose() {
    _liveCtrl.dispose();
    _liveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final isLive = m.isLive();
    final isCompleted = m.isCompleted();
    final hasScore = m.team1Score != null && m.team2Score != null;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // LIVE badge
          if (isLive)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedBuilder(
                animation: _livePulse,
                builder: (_, __) => Opacity(
                  opacity: _livePulse.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.withOpacity(0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MATCH IN PROGRESS',
                          style: GoogleFonts.rajdhani(
                            color: Colors.red,
                            fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _fmtElapsed(_elapsedSeconds),
                          style: GoogleFonts.audiowide(
                            color: Colors.red, fontSize: 13, fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Header: round + match number
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  m.round.toUpperCase(),
                  style: GoogleFonts.audiowide(
                    color: const Color(0xFF7CFC00),
                    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2,
                  ),
                ),
                Text(
                  'MATCH ${m.matchNumber}',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Score display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _teamSide(
                    name: m.team1Name,
                    score: m.team1Score,
                    isWinner: m.winnerId == m.team1Id,
                    align: CrossAxisAlignment.start,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    hasScore ? '${m.team1Score} : ${m.team2Score}' : 'VS',
                    style: hasScore
                        ? GoogleFonts.audiowide(
                            color: Colors.white,
                            fontSize: 40, fontWeight: FontWeight.w900,
                          )
                        : GoogleFonts.audiowide(
                            color: Colors.white38,
                            fontSize: 22, fontWeight: FontWeight.w700,
                          ),
                  ),
                ),
                Expanded(
                  child: _teamSide(
                    name: m.team2Name,
                    score: m.team2Score,
                    isWinner: m.winnerId == m.team2Id,
                    align: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Match details
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                _infoRow(Icons.place, 'Ground', m.ground),
                _divider(),
                _infoRow(
                  Icons.schedule,
                  'Scheduled',
                  _fmtDateTime(m.scheduledTime),
                ),
                if (m.actualStartTime != null) ...[
                  _divider(),
                  _infoRow(
                    Icons.play_circle_outline,
                    'Started',
                    _fmtDateTime(m.actualStartTime!),
                  ),
                ],
                if (isCompleted && m.actualEndTime != null) ...[
                  _divider(),
                  _infoRow(
                    Icons.stop_circle_outlined,
                    'Ended',
                    _fmtDateTime(m.actualEndTime!),
                  ),
                ],
                _divider(),
                _infoRow(
                  Icons.info_outline,
                  'Status',
                  m.status.toUpperCase().replaceAll('_', ' '),
                ),
                if (isCompleted && m.getWinnerName() != null) ...[
                  _divider(),
                  _infoRow(
                    Icons.emoji_events,
                    'Winner',
                    m.getWinnerName()!,
                    highlight: true,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _teamSide({
    required String name,
    int? score,
    bool isWinner = false,
    required CrossAxisAlignment align,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          name,
          textAlign: align == CrossAxisAlignment.start ? TextAlign.left : TextAlign.right,
          style: GoogleFonts.rajdhani(
            color: isWinner ? const Color(0xFF7CFC00) : Colors.white,
            fontSize: 15, fontWeight: FontWeight.w800,
          ),
        ),
        if (isWinner) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (align == CrossAxisAlignment.end) const SizedBox(width: 4),
              const Icon(Icons.emoji_events, size: 14, color: Color(0xFFFFD700)),
              const SizedBox(width: 4),
              Text(
                'WINNER',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFFFD700),
                  fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: highlight ? const Color(0xFFFFD700) : Colors.white38),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.rajdhani(
              color: highlight ? const Color(0xFFFFD700) : Colors.white,
              fontSize: 13, fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.white10);

  String _fmtElapsed(int s) {
    final m = s ~/ 60;
    final sec = (s % 60).toString().padLeft(2, '0');
    return "$m'$sec\"";
  }

  String _fmtDateTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day}/${d.month}/${d.year} $h:$m $ap';
  }
}
