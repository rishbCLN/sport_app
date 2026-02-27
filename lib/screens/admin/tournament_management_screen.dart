import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/tournament.dart';
import '../../models/tournament_team.dart';
import '../../services/tournament_service.dart';
import '../../widgets/bracket_view.dart';
import 'match_management_screen.dart';

Color _sportColor(String sport) {
  switch (sport) {
    case 'Football': return const Color(0xFF2196F3);
    case 'Badminton': return const Color(0xFF4CAF50);
    case 'Cricket': return const Color(0xFFFF9800);
    default: return const Color(0xFF7CFC00);
  }
}

/// Admin screen to manage a specific tournament.
class TournamentManagementScreen extends StatefulWidget {
  final String tournamentId;

  const TournamentManagementScreen({Key? key, required this.tournamentId})
      : super(key: key);

  @override
  State<TournamentManagementScreen> createState() =>
      _TournamentManagementScreenState();
}

class _TournamentManagementScreenState
    extends State<TournamentManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  Tournament? _tournament;
  List<TournamentTeam> _teams = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
    TournamentService.instance.addListener(_load);
  }

  void _load() {
    if (!mounted) return;
    setState(() {
      _tournament = TournamentService.instance.getTournamentById(widget.tournamentId);
      _teams = TournamentService.instance.getTeamsForTournament(widget.tournamentId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    TournamentService.instance.removeListener(_load);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tournament == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Tournament not found')),
      );
    }
    final t = _tournament!;
    final color = _sportColor(t.sport);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7CFC00)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MANAGE TOURNAMENT',
                style: TextStyle(
                    color: Color(0xFF7CFC00),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5)),
            Text(t.name,
                style: GoogleFonts.rajdhani(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF7CFC00),
          labelColor: const Color(0xFF7CFC00),
          unselectedLabelColor: Colors.white38,
          labelStyle: GoogleFonts.rajdhani(
              fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8),
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'TEAMS'),
            Tab(text: 'BRACKET'),
            Tab(text: 'SCHEDULE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(tournament: t, teams: _teams, color: color),
          _AdminTeamsTab(
              tournament: t, teams: _teams, color: color, onRefresh: _load),
          BracketView(
            tournament: t,
            isAdmin: true,
            onMatchTap: (m) => MatchManagementSheet.show(context, m),
          ),
          _AdminScheduleTab(tournament: t, color: color),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Delete Tournament',
            style: GoogleFonts.audiowide(color: Colors.red, fontSize: 14)),
        content: Text(
          'This will permanently delete "${_tournament?.name}". This cannot be undone.',
          style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.rajdhani(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              TournamentService.instance.deleteTournament(widget.tournamentId);
              Navigator.pop(context); // dialog
              Navigator.pop(context); // management screen
            },
            child: Text('DELETE',
                style: GoogleFonts.rajdhani(
                    fontSize: 14, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ─── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final Tournament tournament;
  final List<TournamentTeam> teams;
  final Color color;

  const _OverviewTab({required this.tournament, required this.teams, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    final fill = t.maxTeams == 0 ? 0.0 : t.currentTeams / t.maxTeams;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), Colors.transparent],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _statusBadge(t.status),
                    const Spacer(),
                    if (t.prizePool != null)
                      Text(t.prizePool!,
                          style: GoogleFonts.rajdhani(
                              color: const Color(0xFFFFD700),
                              fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(t.name,
                    style: GoogleFonts.audiowide(
                        color: Colors.white,
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${t.sport} · ${t.format} · ${t.venue}',
                    style: GoogleFonts.rajdhani(
                        color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Registration progress
          _sectionHeader('REGISTRATION PROGRESS'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF121212), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${t.currentTeams} teams registered',
                        style: GoogleFonts.rajdhani(
                            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('of ${t.maxTeams} max',
                        style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: fill, minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Timeline
          _sectionHeader('TIMELINE'),
          _timelineCard(t),
          const SizedBox(height: 16),
          // Stats
          _sectionHeader('MATCH STATS'),
          Row(
            children: [
              Expanded(child: _miniStat('Total', '${t.matchSchedule.length}', Icons.sports, color)),
              const SizedBox(width: 8),
              Expanded(child: _miniStat('Live', '${t.matchSchedule.where((m) => m.isLive()).length}', Icons.fiber_manual_record, Colors.red)),
              const SizedBox(width: 8),
              Expanded(child: _miniStat('Done', '${t.matchSchedule.where((m) => m.isCompleted()).length}', Icons.check_circle, const Color(0xFF4CAF50))),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final labels = {
      'upcoming': 'UPCOMING',
      'registration_open': 'REGISTRATION OPEN',
      'ongoing': 'LIVE',
      'completed': 'COMPLETED',
    };
    final colors = {
      'upcoming': const Color(0xFF2196F3),
      'registration_open': const Color(0xFF4CAF50),
      'ongoing': const Color(0xFFF44336),
      'completed': const Color(0xFF9E9E9E),
    };
    final c = colors[status] ?? Colors.white38;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.5)),
      ),
      child: Text(labels[status] ?? status.toUpperCase(),
          style: GoogleFonts.rajdhani(
              color: c, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
    );
  }

  Widget _timelineCard(Tournament t) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _timelineRow('Registration Opens', t.createdAt, isFirst: true),
          _timelineRow('Registration Deadline', t.registrationDeadline),
          _timelineRow('Tournament Start', t.startDate),
          _timelineRow('Tournament End', t.endDate, isLast: true),
        ],
      ),
    );
  }

  Widget _timelineRow(String label, DateTime date,
      {bool isFirst = false, bool isLast = false}) {
    final isPast = DateTime.now().isAfter(date);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPast ? const Color(0xFF7CFC00) : Colors.white24,
              ),
            ),
            if (!isLast)
              Container(width: 1, height: 36, color: Colors.white10),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.rajdhani(
                        color: isPast ? Colors.white : Colors.white60,
                        fontSize: 13, fontWeight: FontWeight.w700)),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: GoogleFonts.audiowide(
              color: const Color(0xFF7CFC00),
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.8)),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.audiowide(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Admin Teams Tab ───────────────────────────────────────────────────────────

class _AdminTeamsTab extends StatelessWidget {
  final Tournament tournament;
  final List<TournamentTeam> teams;
  final Color color;
  final VoidCallback onRefresh;

  const _AdminTeamsTab({
    required this.tournament,
    required this.teams,
    required this.color,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = tournament.currentTeams >= tournament.maxTeams;

    return Column(
      children: [
        if (isFull)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.account_tree),
                label: const Text('GENERATE BRACKET'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7CFC00),
                  foregroundColor: Colors.black,
                  textStyle: GoogleFonts.rajdhani(
                      fontSize: 15, fontWeight: FontWeight.w800),
                ),
                onPressed: () => _generateBracket(context),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.orange, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Waiting for more teams (${tournament.currentTeams}/${tournament.maxTeams})',
                      style: GoogleFonts.rajdhani(color: Colors.orange, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: teams.isEmpty
              ? Center(
                  child: Text('No teams registered',
                      style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 14)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: teams.length,
                  itemBuilder: (context, i) {
                    final team = teams[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121212),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.shield, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(team.name,
                                    style: GoogleFonts.rajdhani(
                                        color: Colors.white,
                                        fontSize: 14, fontWeight: FontWeight.w800)),
                                Text('Cap: ${team.captainName} · ${team.playerIds.length} players',
                                    style: GoogleFonts.rajdhani(
                                        color: Colors.white60, fontSize: 11)),
                              ],
                            ),
                          ),
                          if (team.hostelBlock != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(team.hostelBlock!,
                                  style: GoogleFonts.rajdhani(
                                      color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _generateBracket(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bracket generated for ${tournament.name}!',
            style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}

// ─── Admin Schedule Tab ────────────────────────────────────────────────────────

class _AdminScheduleTab extends StatelessWidget {
  final Tournament tournament;
  final Color color;

  const _AdminScheduleTab({required this.tournament, required this.color});

  @override
  Widget build(BuildContext context) {
    final matches = [...tournament.matchSchedule]
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    if (matches.isEmpty) {
      return Center(
        child: Text('No matches scheduled',
            style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 14)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, i) {
        final m = matches[i];
        Color sc;
        switch (m.status) {
          case 'live': sc = Colors.red; break;
          case 'completed': sc = const Color(0xFF4CAF50); break;
          case 'postponed': sc = Colors.orange; break;
          default: sc = Colors.white38;
        }
        return GestureDetector(
          onTap: () => MatchManagementSheet.show(context, m),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sc.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${m.team1Name} vs ${m.team2Name}',
                          style: GoogleFonts.rajdhani(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis),
                      Text('${m.round} · M${m.matchNumber} · ${m.ground}',
                          style: GoogleFonts.rajdhani(
                              color: color, fontSize: 11)),
                      Text(_fmtDateTime(m.scheduledTime),
                          style: GoogleFonts.rajdhani(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: sc.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(m.status.toUpperCase(),
                          style: GoogleFonts.rajdhani(
                              color: sc, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                    if (m.team1Score != null) ...[
                      const SizedBox(height: 4),
                      Text('${m.team1Score} – ${m.team2Score}',
                          style: GoogleFonts.audiowide(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                    const SizedBox(height: 4),
                    const Icon(Icons.edit, size: 14, color: Color(0xFF7CFC00)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmtDateTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day}/${d.month}/${d.year} $h:$m $ap';
  }
}
