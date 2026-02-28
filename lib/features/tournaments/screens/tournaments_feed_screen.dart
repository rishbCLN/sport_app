import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/volt_button.dart';
import '../../../core/widgets/ambient_particles.dart';
import '../../../core/widgets/prism_widgets.dart';
import '../../../models/tournament.dart';
import '../../../services/tournament_service.dart';
import 'tournament_detail_screen.dart';
import '../../../features/admin/screens/admin_dashboard_screen.dart';

/// PRISM Tournament Command Center.
///
/// Layout:
/// 1. Hero banner carousel (rotating every 5s)
/// 2. Filter rail (sport + status chips)
/// 3. Tournament card list (HolographicCards)
///
/// Hidden admin access: triple-tap on header label within 2s.
class TournamentsFeedScreen extends StatefulWidget {
  const TournamentsFeedScreen({Key? key}) : super(key: key);

  @override
  State<TournamentsFeedScreen> createState() =>
      _TournamentsFeedScreenState();
}

class _TournamentsFeedScreenState
    extends State<TournamentsFeedScreen>
    with SingleTickerProviderStateMixin {
  List<Tournament> _tournaments = [];
  String _sportFilter = 'All';
  String _statusFilter = 'All';

  // Carousel
  final PageController _bannerCtrl = PageController();
  Timer? _bannerTimer;
  int _bannerPage = 0;

  // Admin hidden access — triple-tap within 2s
  int _headerTapCount = 0;
  Timer? _tapResetTimer;

  @override
  void initState() {
    super.initState();
    _load();
    TournamentService.instance.addListener(_load);
    _startBannerAutoScroll();
  }

  void _load() {
    if (mounted) {
      setState(() {
        _tournaments = TournamentService.instance.getTournaments();
      });
    }
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _tournaments.isEmpty) return;
      final next =
          (_bannerPage + 1) % _tournaments.length.clamp(1, 5);
      _bannerCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _bannerPage = next);
    });
  }

  @override
  void dispose() {
    TournamentService.instance.removeListener(_load);
    _bannerTimer?.cancel();
    _tapResetTimer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  void _onHeaderTap() {
    _tapResetTimer?.cancel();
    _headerTapCount++;
    _tapResetTimer = Timer(const Duration(seconds: 2), () {
      _headerTapCount = 0;
    });
    if (_headerTapCount >= 3) {
      _headerTapCount = 0;
      _tapResetTimer?.cancel();
      _navigateToAdmin();
    }
  }

  void _navigateToAdmin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            const AdminDashboardScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  List<Tournament> get _filtered {
    return _tournaments.where((t) {
      if (_sportFilter != 'All' &&
          t.sport.toLowerCase() != _sportFilter.toLowerCase()) {
        return false;
      }
      if (_statusFilter != 'All') {
        if (_statusFilter == 'Live' && t.status != 'ongoing') {
          return false;
        }
        if (_statusFilter == 'Upcoming' &&
            t.status != 'upcoming' &&
            t.status != 'registration_open') {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AmbientParticles(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            // ── App bar ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildAppBar(),
            ),
            // ── Hero banner ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildHeroBanner(),
            ),
            // ── Filter rail ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildFilterRail(),
            ),
            // ── Tournament list ────────────────────────────────────────────
            if (_filtered.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildTournamentCard(
                            _filtered[i], i)
                        .animate(
                            delay:
                                Duration(milliseconds: i * 60))
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.08, end: 0),
                    childCount: _filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PrismColors.amberShock.withOpacity(0.08),
            PrismColors.abyss,
          ],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _onHeaderTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOURNAMENTS',
                  style: PrismText.hero(
                          color: PrismColors.ghostWhite)
                      .copyWith(fontSize: 32),
                ),
                Text(
                  '${_tournaments.length} EVENTS',
                  style: PrismText.label(
                      color: PrismColors.steelGray)
                      .copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(
                  color: PrismColors.dimGray, width: 1),
              color: PrismColors.pitch,
            ),
            child: const Icon(Icons.search,
                color: PrismColors.steelGray, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Hero banner ───────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    if (_tournaments.isEmpty) {
      return _buildEmptyBanner();
    }

    final bannerTournaments = _tournaments.take(5).toList();

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerCtrl,
            itemCount: bannerTournaments.length,
            onPageChanged: (i) => setState(() => _bannerPage = i),
            itemBuilder: (_, i) =>
                _buildBannerPage(bannerTournaments[i]),
          ),
          // Page dots
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(bannerTournaments.length,
                  (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 3),
                  width: _bannerPage == i ? 18 : 6,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _bannerPage == i
                        ? PrismColors.ghostWhite
                        : PrismColors.steelGray,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerPage(Tournament t) {
    final accent = PrismColors.sportAccent(t.sport);
    final isLive = t.status == 'ongoing';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(0.15),
            PrismColors.pitch,
            accent.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              SportIconBadge(sport: t.sport),
              const SizedBox(width: 8),
              if (isLive) ...[
                LiveBadge(),
              ] else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: PrismColors.concrete,
                  child: Text(
                    _statusLabel(t.status).toUpperCase(),
                    style: PrismText.tag(
                        color: PrismColors.steelGray),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            t.name.toUpperCase(),
            style: PrismText.display(color: PrismColors.ghostWhite)
                .copyWith(fontSize: 22),
            maxLines: 2,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${t.currentTeams}/${t.maxTeams} TEAMS',
                style: PrismText.label(color: accent)
                    .copyWith(fontSize: 11),
              ),
              if (t.prizePool != null) ...[
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: PrismColors.dimGray,
                ),
                Text(
                  '🏆 ${t.prizePool}',
                  style: PrismText.caption(
                      color: PrismColors.steelGray),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          VoltButton(
            label: t.canRegister()
                ? 'REGISTER NOW →'
                : 'VIEW TOURNAMENT →',
            accentColor: accent,
            height: 40,
            onTap: () => _openTournament(t),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 160,
      decoration: BoxDecoration(
        color: PrismColors.pitch,
        border: Border.all(
            color: PrismColors.concrete, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🏆',
                style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            Text(
              'NO TOURNAMENTS YET',
              style: PrismText.label(
                  color: PrismColors.dimGray),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter rail ───────────────────────────────────────────────────────────

  Widget _buildFilterRail() {
    final sportFilters = [
      'All', 'Football', 'Badminton', 'Cricket'
    ];
    final statusFilters = ['All', 'Live', 'Upcoming'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: sportFilters.map((f) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PrismFilterChip(
                  label: f,
                  isSelected: _sportFilter == f,
                  accentColor: PrismColors.voltGreen,
                  onTap: () =>
                      setState(() => _sportFilter = f),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: statusFilters.map((f) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PrismFilterChip(
                  label: f,
                  isSelected: _statusFilter == f,
                  accentColor: PrismColors.redAlert,
                  onTap: () =>
                      setState(() => _statusFilter = f),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${_filtered.length} TOURNAMENT${_filtered.length != 1 ? 'S' : ''}',
            style: PrismText.label(
                    color: PrismColors.dimGray)
                .copyWith(fontSize: 10),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Tournament card ───────────────────────────────────────────────────────

  Widget _buildTournamentCard(Tournament t, int idx) {
    final accent = PrismColors.sportAccent(t.sport);
    final isLive = t.status == 'ongoing';
    final progress = t.maxTeams > 0
        ? t.currentTeams / t.maxTeams
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HolographicCard(
        accentColor: accent,
        isLive: isLive,
        onTap: () => _openTournament(t),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: sport + status
            Row(
              children: [
                SportIconBadge(sport: t.sport),
                const Spacer(),
                if (isLive)
                  LiveBadge()
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    color: PrismColors.concrete,
                    child: Text(
                      _statusLabel(t.status).toUpperCase(),
                      style: PrismText.tag(
                          color: PrismColors.steelGray),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Tournament name
            Text(
              t.name,
              style: PrismText.title(
                      color: PrismColors.ghostWhite)
                  .copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              '${t.format.toUpperCase()} • ${t.currentTeams}/${t.maxTeams} TEAMS',
              style: PrismText.caption(
                  color: PrismColors.steelGray),
            ),
            const SizedBox(height: 12),
            // Progress bar
            Stack(
              children: [
                Container(
                    height: 3,
                    color: PrismColors.concrete),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: accent,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toInt()}% FILLED',
                  style: PrismText.caption(
                      color: accent.withOpacity(0.7)),
                ),
                Text(
                  '📅 ${_dateLabel(t.startDate)}',
                  style: PrismText.caption(
                      color: PrismColors.dimGray),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: VoltButton(
                    label: 'VIEW BRACKET →',
                    variant: VoltButtonVariant.ghost,
                    accentColor: accent,
                    height: 40,
                    fullWidth: true,
                    onTap: () => _openTournament(t),
                  ),
                ),
                if (isLive) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: VoltButton(
                      label: 'LIVE SCORES →',
                      accentColor: PrismColors.redAlert,
                      height: 40,
                      fullWidth: true,
                      onTap: () => _openTournament(t),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🏆', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'NO TOURNAMENTS FOUND',
              style: PrismText.label(
                  color: PrismColors.dimGray),
            ),
            const SizedBox(height: 8),
            Text(
              'No events match your current filters',
              style: PrismText.body(),
            ),
          ],
        ),
      ),
    );
  }

  void _openTournament(Tournament t) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            TournamentDetailScreen(tournament: t),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(
              opacity: CurvedAnimation(
                  parent: anim, curve: Curves.easeIn),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'registration_open':
        return 'OPEN';
      case 'upcoming':
        return 'UPCOMING';
      case 'ongoing':
        return 'LIVE';
      case 'completed':
        return 'COMPLETED';
      default:
        return status.toUpperCase();
    }
  }

  String _dateLabel(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
