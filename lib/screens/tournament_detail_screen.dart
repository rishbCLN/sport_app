import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tournament.dart';
import '../models/tournament_team.dart';
import '../services/tournament_service.dart';
import '../widgets/bracket_view.dart';
import 'match_detail_screen.dart';

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

/// Full tournament detail screen accessible to users.
class TournamentDetailScreen extends StatefulWidget {
  final String tournamentId;

  const TournamentDetailScreen({Key? key, required this.tournamentId})
      : super(key: key);

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Tournament? _tournament;
  List<TournamentTeam> _teams = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _load();
    TournamentService.instance.addListener(_load);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  void _load() {
    if (!mounted) return;
    setState(() {
      _tournament =
          TournamentService.instance.getTournamentById(widget.tournamentId);
      _teams = TournamentService.instance
          .getTeamsForTournament(widget.tournamentId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    TournamentService.instance.removeListener(_load);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tournament == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('TOURNAMENT')),
        body: const Center(child: Text('Tournament not found')),
      );
    }
    final t = _tournament!;
    final color = _sportColor(t.sport);

    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(t, color, innerBoxIsScrolled),
        ],
        body: Column(
          children: [
            // Tab bar
            Container(
              color: const Color(0xFF0D0D0D),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: color,
                labelColor: color,
                unselectedLabelColor: Colors.white38,
                labelStyle: GoogleFonts.rajdhani(
                  fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.8,
                ),
                tabs: const [
                  Tab(text: 'INFO'),
                  Tab(text: 'TEAMS'),
                  Tab(text: 'BRACKET'),
                  Tab(text: 'SCHEDULE'),
                  Tab(text: 'LEADERBOARD'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _InfoTab(tournament: t, teams: _teams, color: color),
                  _TeamsTab(teams: _teams, color: color),
                  BracketView(
                    tournament: t,
                    onMatchTap: (m) => MatchDetailSheet.show(context, m),
                  ),
                  _ScheduleTab(tournament: t, color: color),
                  _LeaderboardTab(teams: _teams, sport: t.sport, color: color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Tournament t, Color color, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF7CFC00)),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.3), Colors.black],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 90, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(_sportIcon(t.sport), color: color, size: 20),
                  const SizedBox(width: 8),
                  _statusChip(t.status, color),
                  if (t.prizePool != null) ...[
                    const SizedBox(width: 8),
                    _prizeChip(t.prizePool!),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t.name,
                style: GoogleFonts.audiowide(
                  color: Colors.white,
                  fontSize: 18, fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        title: innerBoxIsScrolled
            ? Text(t.name,
                style: GoogleFonts.audiowide(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis)
            : null,
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    final labels = {
      'upcoming': 'UPCOMING',
      'registration_open': 'REGISTRATION OPEN',
      'ongoing': 'LIVE',
      'completed': 'COMPLETED',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        labels[status] ?? status.toUpperCase(),
        style: GoogleFonts.rajdhani(
          color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _prizeChip(String prize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 10, color: Color(0xFFFFD700)),
          const SizedBox(width: 4),
          Text(
            prize,
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFFFD700),
              fontSize: 10, fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Tab ──────────────────────────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  final Tournament tournament;
  final List<TournamentTeam> teams;
  final Color color;

  const _InfoTab({required this.tournament, required this.teams, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick stats row
          Row(
            children: [
              Expanded(child: _statCard('Teams', '${t.currentTeams}/${t.maxTeams}', Icons.group, color)),
              const SizedBox(width: 8),
              Expanded(child: _statCard('Format', t.format.split(' ').first, Icons.account_tree, color)),
              const SizedBox(width: 8),
              Expanded(child: _statCard('Venue', t.venue.replaceAll(' Ground', ''), Icons.place, color)),
            ],
          ),
          const SizedBox(height: 16),
          _sectionHeader('SCHEDULE'),
          _infoCard([
            _dateRow('Start Date', t.startDate),
            _divider(),
            _dateRow('End Date', t.endDate),
            _divider(),
            _dateRow('Reg. Deadline', t.registrationDeadline),
          ]),
          const SizedBox(height: 16),
          if (t.rules != null && t.rules!.isNotEmpty) ...[
            _sectionHeader('RULES'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                t.rules!,
                style: GoogleFonts.rajdhani(
                  color: Colors.white70, fontSize: 14, height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Registration progress
          _sectionHeader('REGISTRATION'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Teams registered',
                        style: GoogleFonts.rajdhani(color: Colors.white60, fontSize: 13)),
                    Text('${t.currentTeams} / ${t.maxTeams}',
                        style: GoogleFonts.rajdhani(
                            color: color, fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: t.maxTeams == 0 ? 0 : t.currentTeams / t.maxTeams,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                if (t.canRegister()) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.group_add),
                      label: const Text('REGISTER YOUR TEAM'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.rajdhani(
                            fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      onPressed: () => _showRegisterFlow(context, t, color),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.audiowide(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          Text(label,
              style: GoogleFonts.rajdhani(
                  color: Colors.white38, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.audiowide(
          color: const Color(0xFF7CFC00),
          fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(children: children),
    );
  }

  Widget _dateRow(String label, DateTime d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 14, color: Colors.white38),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.rajdhani(color: Colors.white60, fontSize: 13)),
          const Spacer(),
          Text(
            '${d.day}/${d.month}/${d.year}',
            style: GoogleFonts.rajdhani(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.white10, indent: 12, endIndent: 12);

  void _showRegisterFlow(BuildContext context, Tournament t, Color color) {
    _TeamRegisterFlow.show(context, t, color);
  }
}

// ─── Teams Tab ─────────────────────────────────────────────────────────────────

class _TeamsTab extends StatelessWidget {
  final List<TournamentTeam> teams;
  final Color color;

  const _TeamsTab({required this.teams, required this.color});

  @override
  Widget build(BuildContext context) {
    if (teams.isEmpty) {
      return Center(
        child: Text(
          'No teams registered yet',
          style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (context, i) {
        final team = teams[i];
        return _teamCard(context, team);
      },
    );
  }

  Widget _teamCard(BuildContext context, TournamentTeam team) {
    return GestureDetector(
      onTap: () => _showTeamDetail(context, team),
      child: Container(
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
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.shield, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(team.name,
                      style: GoogleFonts.rajdhani(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                  Text('Captain: ${team.captainName}',
                      style: GoogleFonts.rajdhani(color: Colors.white60, fontSize: 12)),
                  if (team.hostelBlock != null)
                    Text(team.hostelBlock!,
                        style: GoogleFonts.rajdhani(color: color, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${team.playerIds.length} players',
                    style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTeamDetail(BuildContext context, TournamentTeam team) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(team.name,
                style: GoogleFonts.audiowide(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            if (team.hostelBlock != null)
              Text(team.hostelBlock!,
                  style: GoogleFonts.rajdhani(color: color, fontSize: 13)),
            const SizedBox(height: 16),
            Text('CAPTAIN', style: GoogleFonts.audiowide(color: color, fontSize: 10, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(team.captainName,
                style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Text('PLAYERS', style: GoogleFonts.audiowide(color: color, fontSize: 10, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            ...team.playerNames.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text('${e.key + 1}',
                            style: GoogleFonts.rajdhani(
                                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      Text(e.value,
                          style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Schedule Tab ──────────────────────────────────────────────────────────────

class _ScheduleTab extends StatefulWidget {
  final Tournament tournament;
  final Color color;

  const _ScheduleTab({required this.tournament, required this.color});

  @override
  State<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<_ScheduleTab> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final matches = widget.tournament.matchSchedule
        .where((m) {
          if (_filter == 'Today') {
            final now = DateTime.now();
            return m.scheduledTime.day == now.day &&
                m.scheduledTime.month == now.month;
          }
          if (_filter == 'Live') return m.status == 'live';
          if (_filter == 'Upcoming') return m.status == 'scheduled';
          if (_filter == 'Completed') return m.status == 'completed';
          return true;
        })
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: ['All', 'Live', 'Today', 'Upcoming', 'Completed'].map((f) {
              final selected = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? widget.color.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? widget.color : Colors.white24,
                    ),
                  ),
                  child: Text(
                    f,
                    style: GoogleFonts.rajdhani(
                      color: selected ? widget.color : Colors.white60,
                      fontSize: 13, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: matches.isEmpty
              ? Center(
                  child: Text(
                    'No matches for this filter',
                    style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: matches.length,
                  itemBuilder: (context, i) {
                    final m = matches[i];
                    return _scheduleCard(context, m);
                  },
                ),
        ),
      ],
    );
  }

  Widget _scheduleCard(BuildContext context, match) {
    final m = match as dynamic;
    Color sc;
    switch (m.status as String) {
      case 'live': sc = Colors.red; break;
      case 'completed': sc = const Color(0xFF4CAF50); break;
      case 'postponed': sc = Colors.orange; break;
      default: sc = Colors.white38;
    }
    return GestureDetector(
      onTap: () => MatchDetailSheet.show(context, m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            // Date column
            Container(
              width: 50,
              child: Column(
                children: [
                  Text(
                    '${(m.scheduledTime as DateTime).day}',
                    style: GoogleFonts.audiowide(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _months[(m.scheduledTime as DateTime).month - 1].toUpperCase(),
                    style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              width: 1, height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: Colors.white10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${m.team1Name} vs ${m.team2Name}',
                      style: GoogleFonts.rajdhani(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(m.round as String,
                      style: GoogleFonts.rajdhani(color: widget.color, fontSize: 11)),
                  Text(m.ground as String,
                      style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 11)),
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
                  child: Text(
                    (m.status as String).toUpperCase(),
                    style: GoogleFonts.rajdhani(
                        color: sc, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 4),
                if ((m.team1Score as int?) != null)
                  Text(
                    '${m.team1Score} - ${m.team2Score}',
                    style: GoogleFonts.audiowide(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

// ─── Leaderboard Tab ──────────────────────────────────────────────────────────

class _LeaderboardTab extends StatelessWidget {
  final List<TournamentTeam> teams;
  final String sport;
  final Color color;

  const _LeaderboardTab({required this.teams, required this.sport, required this.color});

  @override
  Widget build(BuildContext context) {
    final sorted = [...teams]..sort((a, b) {
        if (b.points != a.points) return b.points.compareTo(a.points);
        if (b.goalDifference != a.goalDifference) {
          return b.goalDifference.compareTo(a.goalDifference);
        }
        return b.goalsScored.compareTo(a.goalsScored);
      });

    if (sorted.isEmpty) {
      return Center(
        child: Text(
          'Leaderboard available once tournament starts',
          style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 24,
                    child: Text('#', style: _hdrStyle(color))),
                const SizedBox(width: 8),
                Expanded(child: Text('TEAM', style: _hdrStyle(color))),
                SizedBox(width: 28, child: Text('P', style: _hdrStyle(color), textAlign: TextAlign.center)),
                SizedBox(width: 28, child: Text('W', style: _hdrStyle(color), textAlign: TextAlign.center)),
                SizedBox(width: 28, child: Text('L', style: _hdrStyle(color), textAlign: TextAlign.center)),
                SizedBox(width: 34, child: Text('GD', style: _hdrStyle(color), textAlign: TextAlign.center)),
                SizedBox(width: 34, child: Text('PTS', style: _hdrStyle(color), textAlign: TextAlign.center)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...sorted.asMap().entries.map((e) {
            final rank = e.key + 1;
            final team = e.value;
            final isTop = rank <= 3;
            final rankColor = rank == 1
                ? const Color(0xFFFFD700)
                : rank == 2
                    ? const Color(0xFFC0C0C0)
                    : rank == 3
                        ? const Color(0xFFCD7F32)
                        : Colors.white60;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isTop ? color.withOpacity(0.05) : const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isTop ? color.withOpacity(0.2) : Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text('$rank',
                        style: GoogleFonts.audiowide(
                            color: rankColor, fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(team.name,
                        style: GoogleFonts.rajdhani(
                            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                  ),
                  _cell('${team.gamesPlayed}', Colors.white70),
                  _cell('${team.wins}', const Color(0xFF4CAF50)),
                  _cell('${team.losses}', Colors.red),
                  _cell(
                    team.goalDifference >= 0 ? '+${team.goalDifference}' : '${team.goalDifference}',
                    team.goalDifference >= 0 ? const Color(0xFF4CAF50) : Colors.red,
                  ),
                  _cell('${team.points}', color, bold: true),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _cell(String text, Color color, {bool bold = false}) {
    return SizedBox(
      width: bold ? 34 : 28,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.audiowide(
          color: color,
          fontSize: bold ? 13 : 12,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }

  TextStyle _hdrStyle(Color c) => GoogleFonts.audiowide(
        color: c, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1,
      );
}

// ─── Team Registration Flow ────────────────────────────────────────────────────

class _TeamRegisterFlow extends StatefulWidget {
  final Tournament tournament;
  final Color color;

  const _TeamRegisterFlow({required this.tournament, required this.color});

  static void show(BuildContext context, Tournament t, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TeamRegisterFlow(tournament: t, color: color),
    );
  }

  @override
  State<_TeamRegisterFlow> createState() => _TeamRegisterFlowState();
}

class _TeamRegisterFlowState extends State<_TeamRegisterFlow> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  final _playerCtrls = List.generate(6, (_) => TextEditingController());
  String? _nameError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final c in _playerCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            // Step indicator
            Row(
              children: List.generate(3, (i) {
                final active = i == _step;
                final done = i < _step;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done
                          ? widget.color
                          : active
                              ? widget.color.withOpacity(0.6)
                              : Colors.white10,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            if (_step == 0) _stepTeamName(),
            if (_step == 1) _stepCaptain(),
            if (_step == 2) _stepPlayers(),
          ],
        ),
      ),
    );
  }

  Widget _stepTeamName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('STEP 1: TEAM NAME',
            style: GoogleFonts.audiowide(
                color: widget.color, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 14),
        TextField(
          controller: _nameCtrl,
          style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
          maxLength: 30,
          decoration: InputDecoration(
            hintText: 'e.g. A Block Strikers',
            errorText: _nameError,
            labelText: 'Team Name',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.trim().length < 3) {
                setState(() => _nameError = 'Min 3 characters');
                return;
              }
              setState(() { _nameError = null; _step = 1; });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: widget.color, foregroundColor: Colors.black),
            child: Text('NEXT',
                style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Widget _stepCaptain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('STEP 2: CAPTAIN',
            style: GoogleFonts.audiowide(
                color: widget.color, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: widget.color, size: 24),
              const SizedBox(width: 12),
              Text('You are the team captain',
                  style: GoogleFonts.rajdhani(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _step = 2),
            style: ElevatedButton.styleFrom(
                backgroundColor: widget.color, foregroundColor: Colors.black),
            child: Text('NEXT',
                style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Widget _stepPlayers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('STEP 3: ADD PLAYERS',
            style: GoogleFonts.audiowide(
                color: widget.color, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 14),
        ...List.generate(6, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _playerCtrls[i],
                style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Player ${i + 1}${i == 0 ? " (You)" : ""}',
                  prefixIcon: Icon(Icons.person, color: widget.color, size: 18),
                ),
              ),
            )),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: Text('REGISTER TEAM',
                style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
                backgroundColor: widget.color, foregroundColor: Colors.black),
            onPressed: _submitRegistration,
          ),
        ),
      ],
    );
  }

  void _submitRegistration() {
    final names = _playerCtrls.map((c) => c.text.trim()).toList();
    final filled = names.where((n) => n.isNotEmpty).length;
    if (filled < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill at least 4 player names')),
      );
      return;
    }

    final id = TournamentService.instance.generateId();
    final team = TournamentTeam(
      id: 'team_$id',
      name: _nameCtrl.text.trim(),
      captainId: 'current_user',
      captainName: 'You',
      playerIds: List.generate(filled, (i) => 'player_$i'),
      playerNames: names.where((n) => n.isNotEmpty).toList(),
      tournamentId: widget.tournament.id,
    );
    TournamentService.instance.addTeam(team);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${team.name} registered successfully!',
          style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}
