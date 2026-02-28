import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/volt_button.dart';
import '../../../core/widgets/ambient_particles.dart';
import '../../../core/widgets/bracket_tree.dart';
import '../../../core/widgets/prism_widgets.dart';
import '../../../models/tournament.dart';
import '../../../models/match.dart';
import '../../../models/tournament_team.dart';
import '../../../services/tournament_service.dart';

/// PRISM Tournament Detail — Bracket / Schedule / Teams / Info tabs.
class TournamentDetailScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailScreen({
    Key? key,
    required this.tournament,
  }) : super(key: key);

  @override
  State<TournamentDetailScreen> createState() =>
      _TournamentDetailScreenState();
}

class _TournamentDetailScreenState
    extends State<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<TournamentMatch> _matches = [];
  List<TournamentTeam> _teams = [];
  bool _loading = true;

  Tournament get t => widget.tournament;
  Color get accent => PrismColors.sportAccent(t.sport);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _load();
    TournamentService.instance.addListener(_load);
  }

  void _load() {
    if (!mounted) return;
    // Refresh the tournament from service to get latest matchSchedule
    final fresh =
        TournamentService.instance.getTournamentById(t.id) ?? t;
    final teams =
        TournamentService.instance.getTeamsForTournament(t.id);
    setState(() {
      _matches = fresh.matchSchedule;
      _teams = teams;
      _loading = false;
    });
  }

  @override
  void dispose() {
    TournamentService.instance.removeListener(_load);
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AmbientParticles(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: NestedScrollView(
          headerSliverBuilder: (ctx, inner) => [
            SliverToBoxAdapter(child: _buildHeroHeader()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabCtrl: _tabCtrl,
                accent: accent,
                tabs: const [
                  'BRACKET',
                  'SCHEDULE',
                  'TEAMS',
                  'INFO',
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildBracketTab(),
              _buildScheduleTab(),
              _buildTeamsTab(),
              _buildInfoTab(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero header ───────────────────────────────────────────────────────────

  Widget _buildHeroHeader() {
    final isLive = t.status == 'ongoing';
    final safePad = MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(0.25),
            PrismColors.pitch,
            PrismColors.abyss,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, safePad + 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PrismColors.concrete,
                    border: Border.all(
                        color: accent.withOpacity(0.4), width: 1),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: PrismColors.ghostWhite, size: 18),
                ),
              ),
              const Spacer(),
              if (isLive) const LiveBadge(),
              const SizedBox(width: 8),
              SportIconBadge(sport: t.sport),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            t.name.toUpperCase(),
            style: PrismText.hero(color: PrismColors.ghostWhite)
                .copyWith(fontSize: 26),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoChip(t.format.toUpperCase(), accent),
              const SizedBox(width: 8),
              _infoChip(
                '${t.currentTeams}/${t.maxTeams} TEAMS',
                PrismColors.steelGray,
              ),
              if (t.prizePool != null) ...[
                const SizedBox(width: 8),
                _infoChip('🏆 ${t.prizePool}',
                    PrismColors.amberShock),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Registration bar
          if (t.canRegister())
            VoltButton(
              label: 'REGISTER YOUR TEAM →',
              accentColor: accent,
              fullWidth: true,
              height: 44,
              onTap: () => _showRegistrationSnackbar(),
            ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(
            color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: PrismText.tag(color: color),
      ),
    );
  }

  // ── BRACKET tab ───────────────────────────────────────────────────────────

  Widget _buildBracketTab() {
    if (_loading) {
      return _buildLoading();
    }
    if (_matches.isEmpty) {
      return _buildTabEmpty(
        icon: '🏆',
        message: 'BRACKET NOT GENERATED',
        sub: 'Matches will appear once the tournament begins',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: BracketTree(
        matches: _matches,
        accentColor: accent,
      ),
    );
  }

  // ── SCHEDULE tab ──────────────────────────────────────────────────────────

  Widget _buildScheduleTab() {
    if (_loading) return _buildLoading();
    if (_matches.isEmpty) {
      return _buildTabEmpty(
        icon: '📅',
        message: 'NO MATCHES SCHEDULED',
        sub: 'Check back once the tournament begins',
      );
    }

    final groups = <String, List<TournamentMatch>>{};
    for (final m in _matches) {
      groups.putIfAbsent(m.round, () => []).add(m);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: groups.length,
      itemBuilder: (ctx, i) {
        final round = groups.keys.elementAt(i);
        final roundMatches = groups[round]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                round.toUpperCase(),
                style: PrismText.label(color: accent)
                    .copyWith(fontSize: 11),
              ),
            ),
            ...roundMatches.asMap().entries.map((e) =>
                _buildMatchCard(e.value, e.key)
                    .animate(
                        delay: Duration(milliseconds: e.key * 60))
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: 0.06, end: 0)),
          ],
        );
      },
    );
  }

  Widget _buildMatchCard(TournamentMatch m, int idx) {
    final isLive = m.status == 'live';
    final isDone = m.status == 'completed';
    final matchAccent =
        isLive ? PrismColors.redAlert : accent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: HolographicCard(
        accentColor: matchAccent,
        isLive: isLive,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '#${m.matchNumber}',
                  style: PrismText.mono(
                      fontSize: 10,
                      color: PrismColors.dimGray),
                ),
                const Spacer(),
                if (isLive) const LiveBadge(),
                if (!isLive)
                  Text(
                    m.status.toUpperCase(),
                    style: PrismText.tag(
                        color: PrismColors.dimGray),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.team1Name,
                        style: PrismText.title(
                            color: isDone &&
                                    (m.team1Score ?? 0) >
                                        (m.team2Score ?? 0)
                                ? accent
                                : PrismColors.ghostWhite),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  color: PrismColors.concrete,
                  child: Text(
                    isDone || isLive
                        ? '${m.team1Score ?? 0} : ${m.team2Score ?? 0}'
                        : 'VS',
                    style: PrismText.mono(
                      fontSize: 14,
                      color: isLive
                          ? PrismColors.redAlert
                          : PrismColors.ghostWhite,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(
                        m.team2Name,
                        style: PrismText.title(
                            color: isDone &&
                                    (m.team2Score ?? 0) >
                                        (m.team1Score ?? 0)
                                ? accent
                                : PrismColors.ghostWhite),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (m.scheduledTime != null) ...[
              const SizedBox(height: 8),
              Text(
                '📅 ${_formatTime(m.scheduledTime!)}',
                style: PrismText.caption(
                    color: PrismColors.dimGray),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── TEAMS tab ─────────────────────────────────────────────────────────────

  Widget _buildTeamsTab() {
    if (_loading) return _buildLoading();
    if (_teams.isEmpty) {
      return _buildTabEmpty(
        icon: '👥',
        message: 'NO TEAMS REGISTERED',
        sub: 'Registration is open for this tournament',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: _teams.length,
      itemBuilder: (ctx, i) => _buildTeamCard(_teams[i], i),
    );
  }

  Widget _buildTeamCard(TournamentTeam team, int idx) {
    return HolographicCard(
      accentColor: accent,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                color: accent.withOpacity(0.2),
                child: Center(
                  child: Text(
                    '${idx + 1}',
                    style: PrismText.mono(
                        fontSize: 12, color: accent),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.name,
                style: PrismText.title(
                        color: PrismColors.ghostWhite)
                    .copyWith(fontSize: 13),
                maxLines: 2,
              ),
              const SizedBox(height: 2),
              Text(
                '${team.playerNames.length} PLAYERS',
                style: PrismText.caption(
                    color: PrismColors.steelGray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── INFO tab ──────────────────────────────────────────────────────────────

  Widget _buildInfoTab() {
    final rows = <MapEntry<String, String>>[
      MapEntry('SPORT', t.sport.toUpperCase()),
      MapEntry('FORMAT', t.format.toUpperCase()),
      MapEntry('STATUS', t.status.toUpperCase()),
      MapEntry('START DATE', _formatDate(t.startDate)),
      MapEntry('TEAMS MAX', '${t.maxTeams}'),
      MapEntry('REGISTERED', '${t.currentTeams}'),
      if (t.prizePool != null)
        MapEntry('PRIZE POOL', t.prizePool!),
      if (t.rules != null && t.rules!.isNotEmpty)
        MapEntry('RULES', t.rules!),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: rows.length,
      itemBuilder: (ctx, i) {
        final row = rows[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: HolographicCard(
            accentColor: accent,
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    row.key,
                    style: PrismText.label(
                        color: PrismColors.steelGray)
                        .copyWith(fontSize: 10),
                  ),
                ),
                Expanded(
                  child: Text(
                    row.value,
                    style: PrismText.body(
                        color: PrismColors.ghostWhite),
                  ),
                ),
              ],
            ),
          ).animate(
              delay: Duration(milliseconds: i * 40)),
        );
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: accent,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'LOADING...',
            style: PrismText.label(color: PrismColors.dimGray),
          ),
        ],
      ),
    );
  }

  Widget _buildTabEmpty({
    required String icon,
    required String message,
    required String sub,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            message,
            style: PrismText.label(
                color: PrismColors.dimGray),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            style: PrismText.body(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showRegistrationSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PrismColors.concrete,
        content: Text(
          'REGISTRATION FEATURE COMING SOON',
          style: PrismText.label(color: accent),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month} · $h:$m';
  }
}

// ── Pinned tab bar delegate ───────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabCtrl;
  final Color accent;
  final List<String> tabs;

  const _TabBarDelegate({
    required this.tabCtrl,
    required this.accent,
    required this.tabs,
  });

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext ctx,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: PrismColors.pitch,
      child: TabBar(
        controller: tabCtrl,
        isScrollable: false,
        indicatorColor: accent,
        indicatorWeight: 2,
        labelColor: accent,
        unselectedLabelColor: PrismColors.steelGray,
        labelStyle: PrismText.label().copyWith(fontSize: 11),
        unselectedLabelStyle:
            PrismText.label().copyWith(fontSize: 11),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) =>
      old.accent != accent;
}
