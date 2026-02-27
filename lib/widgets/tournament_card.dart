import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tournament.dart';

/// Sport gradient colors
Color _sportColor(String sport) {
  switch (sport) {
    case 'Football':
      return const Color(0xFF2196F3);
    case 'Badminton':
      return const Color(0xFF4CAF50);
    case 'Cricket':
      return const Color(0xFFFF9800);
    default:
      return const Color(0xFF2196F3);
  }
}

Color _sportColorDark(String sport) {
  switch (sport) {
    case 'Football':
      return const Color(0xFF1976D2);
    case 'Badminton':
      return const Color(0xFF388E3C);
    case 'Cricket':
      return const Color(0xFFF57C00);
    default:
      return const Color(0xFF1976D2);
  }
}

IconData _sportIcon(String sport) {
  switch (sport) {
    case 'Football':
      return Icons.sports_soccer;
    case 'Badminton':
      return Icons.sports_tennis;
    case 'Cricket':
      return Icons.sports_cricket;
    default:
      return Icons.emoji_events;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'upcoming':
      return const Color(0xFF2196F3);
    case 'registration_open':
      return const Color(0xFF4CAF50);
    case 'ongoing':
      return const Color(0xFFF44336);
    case 'completed':
      return const Color(0xFF9E9E9E);
    default:
      return const Color(0xFF2196F3);
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'upcoming':
      return 'UPCOMING';
    case 'registration_open':
      return 'OPEN';
    case 'ongoing':
      return 'LIVE';
    case 'completed':
      return 'ENDED';
    default:
      return status.toUpperCase();
  }
}

/// Large visual tournament card for the tournaments list screen.
class TournamentCard extends StatefulWidget {
  final Tournament tournament;
  final VoidCallback onTap;
  final VoidCallback? onRegister;

  const TournamentCard({
    Key? key,
    required this.tournament,
    required this.onTap,
    this.onRegister,
  }) : super(key: key);

  @override
  State<TournamentCard> createState() => _TournamentCardState();
}

class _TournamentCardState extends State<TournamentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _countdownTimer;
  Duration _countdown = Duration.zero;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateCountdown();
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final t = widget.tournament;
    Duration diff = Duration.zero;
    if (t.status == 'upcoming' || t.status == 'registration_open') {
      if (now.isBefore(t.startDate)) {
        diff = t.startDate.difference(now);
      }
    }
    if (mounted) setState(() => _countdown = diff);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    final sportColor = _sportColor(t.sport);
    final sportDark = _sportColorDark(t.sport);
    final statusColor = _statusColor(t.status);
    final isLive = t.status == 'ongoing';
    final fillPercent = t.maxTeams == 0 ? 0.0 : t.currentTeams / t.maxTeams;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [sportColor.withOpacity(0.25), const Color(0xFF121212)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLive ? Colors.red.withOpacity(0.6) : sportColor.withOpacity(0.35),
            width: isLive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: sportColor.withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative sport icon background
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                _sportIcon(t.sport),
                size: 120,
                color: sportColor.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Status badge + sport
                  Row(
                    children: [
                      // Sport icon badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: sportColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: sportColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_sportIcon(t.sport), size: 14, color: sportColor),
                            const SizedBox(width: 5),
                            Text(
                              t.sport.toUpperCase(),
                              style: GoogleFonts.rajdhani(
                                color: sportColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Status badge
                      isLive
                          ? AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (_, __) => Opacity(
                                opacity: _pulseAnimation.value,
                                child: _statusBadge(statusColor, isLive),
                              ),
                            )
                          : _statusBadge(statusColor, isLive),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Tournament name
                  Text(
                    t.name,
                    style: GoogleFonts.audiowide(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Format + venue
                  Row(
                    children: [
                      Icon(Icons.format_list_bulleted, size: 12, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(
                        t.format,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.place, size: 12, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(
                        t.venue,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Registration progress
                  Row(
                    children: [
                      Icon(Icons.group, size: 14, color: sportColor),
                      const SizedBox(width: 5),
                      Text(
                        '${t.currentTeams}/${t.maxTeams} teams',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (t.prizePool != null) ...[
                        Icon(Icons.emoji_events, size: 14, color: const Color(0xFFFFD700)),
                        const SizedBox(width: 4),
                        Text(
                          t.prizePool!,
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: fillPercent,
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(sportDark),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Date + action button row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_fmtDate(t.startDate)} – ${_fmtDate(t.endDate)}',
                              style: GoogleFonts.rajdhani(
                                color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_countdown > Duration.zero)
                              Text(
                                'Starts in ${_fmtDuration(_countdown)}',
                                style: GoogleFonts.rajdhani(
                                  color: sportColor, fontSize: 11, fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // CTA button
                      if (t.canRegister() && widget.onRegister != null)
                        _actionButton(
                          label: 'REGISTER',
                          color: sportColor,
                          onTap: widget.onRegister!,
                        )
                      else
                        _actionButton(
                          label: 'VIEW DETAILS',
                          color: sportColor.withOpacity(0.7),
                          onTap: widget.onTap,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(Color color, bool live) {
    final label = _statusLabel(widget.tournament.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (live) ...[
            Container(
              width: 7, height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  String _fmtDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
