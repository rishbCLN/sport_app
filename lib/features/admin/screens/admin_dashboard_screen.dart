import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/volt_button.dart';
import '../../../core/widgets/ambient_particles.dart';
import '../../../core/widgets/stat_counter.dart';
import '../../../core/widgets/prism_widgets.dart';
import '../../../core/widgets/confetti_overlay.dart';
import '../../../models/tournament.dart';
import '../../../models/match.dart';
import '../../../services/tournament_service.dart';

const _kAdminPassword = 'admin123';

/// PRISM Admin Command Center.
///
/// Entry: Password-wall gate, then full admin panel.
/// Capabilities:
///   - Stats overview row
///   - Tournament list with live/completed status
///   - Score editing per match
///   - End match → Confetti reveal
///   - Quick create tournament shortcut
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  bool _authenticated = false;
  List<Tournament> _tournaments = [];
  Tournament? _selectedTournament;

  // Matches come from the selected tournament's matchSchedule
  List<TournamentMatch> get _matches =>
      _selectedTournament?.matchSchedule ?? [];

  @override
  void initState() {
    super.initState();
    TournamentService.instance.addListener(_refresh);
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _tournaments = TournamentService.instance.getTournaments();
      // Refresh selected tournament to pick up matchSchedule changes
      if (_selectedTournament != null) {
        _selectedTournament = TournamentService.instance
            .getTournamentById(_selectedTournament!.id);
      }
    });
  }

  void _selectTournament(Tournament t) {
    setState(() => _selectedTournament = t);
  }

  @override
  void dispose() {
    TournamentService.instance.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AmbientParticles(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _authenticated
            ? _buildDashboard()
            : _PasswordGate(
                onAuthenticated: () {
                  setState(() {
                    _authenticated = true;
                    _tournaments =
                        TournamentService.instance
                            .getTournaments();
                  });
                },
              ),
      ),
    );
  }

  // ── Dashboard ─────────────────────────────────────────────────────────────

  Widget _buildDashboard() {
    return Column(
      children: [
        _buildAppBar(),
        if (_selectedTournament == null)
          Expanded(child: _buildTournamentList())
        else
          Expanded(child: _buildMatchPanel()),
      ],
    );
  }

  Widget _buildAppBar() {
    final safePad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, safePad + 12, 20, 16),
      color: PrismColors.pitch,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_selectedTournament != null) {
                setState(() {
                  _selectedTournament = null;
                });
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: PrismColors.concrete,
                border: Border.all(
                    color: PrismColors.magentaFlare
                        .withOpacity(0.4),
                    width: 1),
              ),
              child: const Icon(Icons.arrow_back,
                  color: PrismColors.ghostWhite, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedTournament != null
                    ? 'MATCH CONTROL'
                    : 'ADMIN COMMAND',
                style: PrismText.hero(
                        color: PrismColors.ghostWhite)
                    .copyWith(fontSize: 22),
              ),
              Text(
                _selectedTournament != null
                    ? _selectedTournament!.name.toUpperCase()
                    : '${_tournaments.length} TOURNAMENTS',
                style: PrismText.label(
                        color: PrismColors.magentaFlare)
                    .copyWith(fontSize: 10),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            color: PrismColors.magentaFlare.withOpacity(0.15),
            child: Text(
              'ADMIN',
              style: PrismText.tag(
                  color: PrismColors.magentaFlare),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tournament list ───────────────────────────────────────────────────────

  Widget _buildTournamentList() {
    final live = _tournaments
        .where((t) => t.status == 'ongoing')
        .length;
    final total = _tournaments.length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildStatsRow(live, total)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOURNAMENTS',
                  style: PrismText.label(
                      color: PrismColors.steelGray)
                      .copyWith(fontSize: 11),
                ),
                GestureDetector(
                  onTap: _showCreateTournamentSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: PrismColors.magentaFlare
                          .withOpacity(0.12),
                      border: Border.all(
                          color: PrismColors.magentaFlare
                              .withOpacity(0.4),
                          width: 1),
                    ),
                    child: Text(
                      '+ NEW TOURNAMENT',
                      style: PrismText.tag(
                          color: PrismColors.magentaFlare),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_tournaments.isEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'NO TOURNAMENTS YET',
                  style: PrismText.label(
                      color: PrismColors.dimGray),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding:
                const EdgeInsets.fromLTRB(16, 0, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildAdminTCard(
                        _tournaments[i], i)
                    .animate(
                        delay:
                            Duration(milliseconds: i * 50))
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: 0.06, end: 0),
                childCount: _tournaments.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow(int live, int total) {
    final completed = _tournaments
        .where((t) => t.status == 'completed')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: StatCounter(
              value: total.toDouble(),
              label: 'TOTAL',
              color: PrismColors.cyanBlitz,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCounter(
              value: live.toDouble(),
              label: 'LIVE',
              color: PrismColors.redAlert,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCounter(
              value: completed.toDouble(),
              label: 'DONE',
              color: PrismColors.voltGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTCard(Tournament t, int idx) {
    final accent = PrismColors.sportAccent(t.sport);
    final isLive = t.status == 'ongoing';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HolographicCard(
        accentColor: accent,
        isLive: isLive,
        onTap: () => _selectTournament(t),
        child: Row(
          children: [
            SportIconBadge(sport: t.sport),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    style: PrismText.title(
                        color: PrismColors.ghostWhite)
                        .copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${t.currentTeams}/${t.maxTeams} teams · ${t.status.toUpperCase()}',
                    style: PrismText.caption(
                        color: PrismColors.steelGray),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isLive) const LiveBadge(),
            const SizedBox(width: 8),
            _smallActionButton(
              icon: Icons.chevron_right,
              color: accent,
              onTap: () => _selectTournament(t),
            ),
            const SizedBox(width: 6),
            _smallActionButton(
              icon: Icons.delete_outline,
              color: PrismColors.redAlert,
              onTap: () => _confirmDelete(t),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          border: Border.all(
              color: color.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }

  // ── Match control panel ───────────────────────────────────────────────────

  Widget _buildMatchPanel() {
    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '📋',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'NO MATCHES YET',
              style: PrismText.label(
                  color: PrismColors.dimGray),
            ),
            const SizedBox(height: 20),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40),
              child: VoltButton(
                label: '+ ADD MATCH',
                accentColor: PrismColors.magentaFlare,
                fullWidth: true,
                height: 44,
                onTap: _showAddMatchSheet,
              ),
            ),
          ],
        ),
      );
    }

    final accent =
        PrismColors.sportAccent(_selectedTournament!.sport);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: _matches.length,
            itemBuilder: (ctx, i) =>
                _buildMatchControlCard(_matches[i], accent)
                    .animate(
                        delay:
                            Duration(milliseconds: i * 40))
                    .fadeIn(duration: 250.ms),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: VoltButton(
            label: '+ ADD MATCH',
            accentColor: PrismColors.magentaFlare,
            fullWidth: true,
            height: 44,
            onTap: _showAddMatchSheet,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchControlCard(
      TournamentMatch m, Color accent) {
    final isLive = m.status == 'live';
    final isDone = m.status == 'completed';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HolographicCard(
        accentColor: isLive ? PrismColors.redAlert : accent,
        isLive: isLive,
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '#${m.matchNumber}  ${m.round.toUpperCase()}',
                  style: PrismText.label(
                          color: PrismColors.steelGray)
                      .copyWith(fontSize: 10),
                ),
                const Spacer(),
                if (isLive) const LiveBadge(),
                if (isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    color: PrismColors.voltGreen
                        .withOpacity(0.15),
                    child: Text(
                      'DONE',
                      style: PrismText.tag(
                          color: PrismColors.voltGreen),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Teams + Score row
            Row(
              children: [
                Expanded(
                  child: Text(
                    m.team1Name,
                    style: PrismText.title(
                        color: PrismColors.ghostWhite)
                        .copyWith(fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  color: PrismColors.concrete,
                  child: Text(
                    '${m.team1Score ?? 0} : ${m.team2Score ?? 0}',
                    style: PrismText.mono(
                      fontSize: 16,
                      color: isLive
                          ? PrismColors.redAlert
                          : PrismColors.ghostWhite,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    m.team2Name,
                    style: PrismText.title(
                        color: PrismColors.ghostWhite)
                        .copyWith(fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            if (!isDone)
              Row(
                children: [
                  if (!isLive) ...[
                    Expanded(
                      child: VoltButton(
                        label: 'START MATCH',
                        accentColor: PrismColors.voltGreen,
                        height: 38,
                        fullWidth: true,
                        onTap: () =>
                            _startMatch(m),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (isLive) ...[
                    Expanded(
                      child: VoltButton(
                        label: 'EDIT SCORES',
                        variant: VoltButtonVariant.ghost,
                        accentColor: PrismColors.cyanBlitz,
                        height: 38,
                        fullWidth: true,
                        onTap: () =>
                            _showScoreEditor(m),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VoltButton(
                        label: 'END MATCH',
                        variant:
                            VoltButtonVariant.danger,
                        accentColor: PrismColors.redAlert,
                        height: 38,
                        fullWidth: true,
                        onTap: () =>
                            _endMatch(m),
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

  // ── Match operations ──────────────────────────────────────────────────────

  void _updateMatchStatus(TournamentMatch m, String status) {
    final updated = TournamentMatch(
      id: m.id, tournamentId: m.tournamentId,
      matchNumber: m.matchNumber, round: m.round,
      team1Id: m.team1Id, team2Id: m.team2Id,
      team1Name: m.team1Name, team2Name: m.team2Name,
      team1Score: m.team1Score, team2Score: m.team2Score,
      winnerId: m.winnerId,
      scheduledTime: m.scheduledTime,
      actualStartTime: status == 'live' ? DateTime.now() : m.actualStartTime,
      actualEndTime: status == 'completed' ? DateTime.now() : m.actualEndTime,
      status: status, ground: m.ground,
    );
    TournamentService.instance.updateMatch(updated);
    HapticFeedback.mediumImpact();
  }

  void _startMatch(TournamentMatch m) =>
      _updateMatchStatus(m, 'live');

  void _endMatch(TournamentMatch m) {
    final winner = (m.team1Score ?? 0) >= (m.team2Score ?? 0)
        ? m.team1Name
        : m.team2Name;
    final winnerId = (m.team1Score ?? 0) >= (m.team2Score ?? 0)
        ? m.team1Id
        : m.team2Id;
    final updated = TournamentMatch(
      id: m.id, tournamentId: m.tournamentId,
      matchNumber: m.matchNumber, round: m.round,
      team1Id: m.team1Id, team2Id: m.team2Id,
      team1Name: m.team1Name, team2Name: m.team2Name,
      team1Score: m.team1Score, team2Score: m.team2Score,
      winnerId: winnerId, scheduledTime: m.scheduledTime,
      actualStartTime: m.actualStartTime,
      actualEndTime: DateTime.now(),
      status: 'completed', ground: m.ground,
    );
    TournamentService.instance.updateMatch(updated);
    HapticFeedback.heavyImpact();
    if (mounted) {
      ConfettiOverlay.show(
        context,
        winnerName: winner,
        accentColor: PrismColors.sportAccent(
            _selectedTournament!.sport),
      );
    }
  }

  void _showScoreEditor(TournamentMatch m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ScoreEditorSheet(
        match: m,
        accent: PrismColors.sportAccent(
            _selectedTournament!.sport),
        onSave: (s1, s2) {
          final updated = TournamentMatch(
            id: m.id, tournamentId: m.tournamentId,
            matchNumber: m.matchNumber, round: m.round,
            team1Id: m.team1Id, team2Id: m.team2Id,
            team1Name: m.team1Name, team2Name: m.team2Name,
            team1Score: s1, team2Score: s2,
            winnerId: m.winnerId,
            scheduledTime: m.scheduledTime,
            actualStartTime: m.actualStartTime,
            actualEndTime: m.actualEndTime,
            status: m.status, ground: m.ground,
          );
          TournamentService.instance.updateMatch(updated);
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  void _showAddMatchSheet() {
    if (_selectedTournament == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddMatchSheet(
        tournament: _selectedTournament!,
        onAdd: (m) {
          final t = _selectedTournament!;
          TournamentService.instance.updateTournament(
            t.copyWith(matchSchedule: [...t.matchSchedule, m]),
          );
        },
      ),
    );
  }

  void _showCreateTournamentSheet() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const _TournamentWizardScreen(),
      ),
    );
  }

  void _confirmDelete(Tournament t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: PrismColors.pitch,
        title: Text(
          'DELETE TOURNAMENT?',
          style:
              PrismText.label(color: PrismColors.redAlert),
        ),
        content: Text(
          'This will permanently remove "${t.name}".',
          style: PrismText.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL',
                style: PrismText.label(
                    color: PrismColors.steelGray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              TournamentService.instance
                  .deleteTournament(t.id);
            },
            child: Text('DELETE',
                style: PrismText.label(
                    color: PrismColors.redAlert)),
          ),
        ],
      ),
    );
  }
}

// ── Password gate ─────────────────────────────────────────────────────────────

class _PasswordGate extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const _PasswordGate({required this.onAuthenticated});

  @override
  State<_PasswordGate> createState() =>
      _PasswordGateState();
}

class _PasswordGateState extends State<_PasswordGate>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  bool _error = false;
  bool _obscure = true;
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.trim() == _kAdminPassword) {
      HapticFeedback.heavyImpact();
      widget.onAuthenticated();
    } else {
      setState(() => _error = true);
      HapticFeedback.vibrate();
      _shakeCtrl.forward(from: 0);
      Timer(
          const Duration(seconds: 2),
          () => setState(() => _error = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final safePad = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(32, safePad + 60, 32, 40),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: PrismColors.concrete,
                  border: Border.all(
                    color: PrismColors.dimGray,
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.arrow_back,
                    color: PrismColors.ghostWhite,
                    size: 18),
              ),
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _shakeCtrl,
            builder: (_, child) {
              final shake = _shakeCtrl.isAnimating
                  ? (8 *
                      math.sin(_shakeCtrl.value * 3 * math.pi))
                  : 0.0;
              return Transform.translate(
                offset: Offset(shake, 0),
                child: child!,
              );
            },
            child: Column(
              children: [
                Text(
                  '🔒',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  'ADMIN ACCESS',
                  style: PrismText.hero(
                          color: PrismColors.ghostWhite)
                      .copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'ENTER COMMAND CODE',
                  style: PrismText.label(
                      color: PrismColors.steelGray)
                      .copyWith(fontSize: 11),
                ),
                const SizedBox(height: 40),
                // Password field
                Container(
                  decoration: BoxDecoration(
                    color: PrismColors.pitch,
                    border: Border.all(
                      color: _error
                          ? PrismColors.redAlert
                          : PrismColors.magentaFlare
                              .withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    obscureText: _obscure,
                    autofocus: true,
                    style: PrismText.mono(
                        fontSize: 16,
                        color: PrismColors.ghostWhite),
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'PASSWORD',
                      hintStyle: PrismText.label(
                          color: PrismColors.dimGray),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                            () => _obscure = !_obscure),
                        child: Icon(
                          _obscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: PrismColors.dimGray,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_error)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'ACCESS DENIED — INVALID CODE',
                      style: PrismText.tag(
                          color: PrismColors.redAlert)
                          .copyWith(fontSize: 11),
                    ),
                  ),
                const SizedBox(height: 24),
                VoltButton(
                  label: 'AUTHENTICATE →',
                  accentColor: PrismColors.magentaFlare,
                  fullWidth: true,
                  height: 48,
                  onTap: _submit,
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}



// ── Score editor sheet ────────────────────────────────────────────────────────

class _ScoreEditorSheet extends StatefulWidget {
  final TournamentMatch match;
  final Color accent;
  final void Function(int s1, int s2) onSave;

  const _ScoreEditorSheet({
    required this.match,
    required this.accent,
    required this.onSave,
  });

  @override
  State<_ScoreEditorSheet> createState() =>
      _ScoreEditorSheetState();
}

class _ScoreEditorSheetState
    extends State<_ScoreEditorSheet> {
  late int _s1;
  late int _s2;

  @override
  void initState() {
    super.initState();
    _s1 = widget.match.team1Score ?? 0;
    _s2 = widget.match.team2Score ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PrismColors.pitch,
        border: Border(
          top: BorderSide(
              color: widget.accent.withOpacity(0.4),
              width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'EDIT SCORES',
            style: PrismText.hero(color: PrismColors.ghostWhite)
                .copyWith(fontSize: 20),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ScoreSpinner(
                  label: widget.match.team1Name,
                  value: _s1,
                  accent: widget.accent,
                  onChanged: (v) =>
                      setState(() => _s1 = v),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: PrismText.mono(
                      fontSize: 28,
                      color: PrismColors.ghostWhite),
                ),
              ),
              Expanded(
                child: _ScoreSpinner(
                  label: widget.match.team2Name,
                  value: _s2,
                  accent: widget.accent,
                  onChanged: (v) =>
                      setState(() => _s2 = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          VoltButton(
            label: 'SAVE SCORES ⚡',
            accentColor: widget.accent,
            fullWidth: true,
            height: 48,
            onTap: () {
              widget.onSave(_s1, _s2);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _ScoreSpinner extends StatelessWidget {
  final String label;
  final int value;
  final Color accent;
  final void Function(int) onChanged;

  const _ScoreSpinner({
    required this.label,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: PrismText.label(
                  color: PrismColors.steelGray)
              .copyWith(fontSize: 10),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _btn(Icons.remove, () {
              if (value > 0) onChanged(value - 1);
            }, accent),
            const SizedBox(width: 12),
            Container(
              width: 60,
              height: 50,
              color: PrismColors.concrete,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: PrismText.mono(
                    fontSize: 24,
                    color: PrismColors.ghostWhite),
              ),
            ),
            const SizedBox(width: 12),
            _btn(Icons.add, () => onChanged(value + 1),
                accent),
          ],
        ),
      ],
    );
  }

  Widget _btn(
      IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          border: Border.all(
              color: color.withOpacity(0.4), width: 1),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

// ── Add match sheet ───────────────────────────────────────────────────────────

class _AddMatchSheet extends StatefulWidget {
  final Tournament tournament;
  final void Function(TournamentMatch) onAdd;

  const _AddMatchSheet({
    required this.tournament,
    required this.onAdd,
  });

  @override
  State<_AddMatchSheet> createState() =>
      _AddMatchSheetState();
}

class _AddMatchSheetState extends State<_AddMatchSheet> {
  final _t1Ctrl = TextEditingController();
  final _t2Ctrl = TextEditingController();
  final _roundCtrl =
      TextEditingController(text: 'Round 1');

  @override
  void dispose() {
    _t1Ctrl.dispose();
    _t2Ctrl.dispose();
    _roundCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final t1 = _t1Ctrl.text.trim();
    final t2 = _t2Ctrl.text.trim();
    final round = _roundCtrl.text.trim();
    if (t1.isEmpty || t2.isEmpty || round.isEmpty) {
      return;
    }

    final id = DateTime.now()
        .millisecondsSinceEpoch
        .toString();
    final m = TournamentMatch(
      id: id,
      tournamentId: widget.tournament.id,
      matchNumber:
          widget.tournament.matchSchedule.length + 1,
      team1Id: t1.toLowerCase().replaceAll(' ', '_'),
      team2Id: t2.toLowerCase().replaceAll(' ', '_'),
      team1Name: t1,
      team2Name: t2,
      round: round,
      status: 'scheduled',
      scheduledTime:
          DateTime.now().add(const Duration(hours: 1)),
      ground: 'Sand Ground',
    );
    widget.onAdd(m);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PrismColors.pitch,
        border: Border(
          top: BorderSide(
              color: PrismColors.magentaFlare, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ADD MATCH',
            style: PrismText.hero(
                    color: PrismColors.ghostWhite)
                .copyWith(fontSize: 20),
          ),
          const SizedBox(height: 20),
          _field('TEAM 1', _t1Ctrl,
              PrismColors.magentaFlare),
          const SizedBox(height: 12),
          _field('TEAM 2', _t2Ctrl,
              PrismColors.magentaFlare),
          const SizedBox(height: 12),
          _field(
              'ROUND', _roundCtrl, PrismColors.cyanBlitz),
          const SizedBox(height: 24),
          VoltButton(
            label: '+ ADD MATCH →',
            accentColor: PrismColors.magentaFlare,
            fullWidth: true,
            height: 48,
            onTap: _submit,
          ),
        ],
      ),
    );
  }

  Widget _field(
      String label, TextEditingController ctrl, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PrismText.label(
                  color: PrismColors.steelGray)
              .copyWith(fontSize: 10),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: PrismColors.concrete,
            border: Border.all(
                color: color.withOpacity(0.3), width: 1),
          ),
          child: TextField(
            controller: ctrl,
            style: PrismText.body(
                color: PrismColors.ghostWhite),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
              hintText: 'Enter $label...',
              hintStyle: PrismText.body(
                  color: PrismColors.dimGray),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Wizard stub ───────────────────────────────────────────────────────────────

class _TournamentWizardScreen extends StatefulWidget {
  const _TournamentWizardScreen();

  @override
  State<_TournamentWizardScreen> createState() =>
      _TournamentWizardScreenState();
}

class _TournamentWizardScreenState
    extends State<_TournamentWizardScreen> {
  int _step = 0;

  final _nameCtrl = TextEditingController();
  String _sport = 'Football';
  String _format = 'knockout';
  int _maxTeams = 8;
  final _prizeCtrl = TextEditingController();

  final _sports = ['Football', 'Badminton', 'Cricket'];
  final _formats = ['knockout', 'round-robin', 'league'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _prizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final now = DateTime.now();
    final t = Tournament(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      sport: _sport,
      format: _format,
      maxTeams: _maxTeams,
      currentTeams: 0,
      status: 'upcoming',
      startDate: now.add(const Duration(days: 7)),
      endDate: now.add(const Duration(days: 14)),
      registrationDeadline:
          now.add(const Duration(days: 5)),
      registeredTeamIds: [],
      matchSchedule: [],
      bracket: {},
      winners: [],
      createdBy: 'admin',
      createdAt: now,
      venue: 'VIT Sports Complex',
      prizePool: _prizeCtrl.text.trim().isEmpty
          ? null
          : _prizeCtrl.text.trim(),
    );

    TournamentService.instance.addTournament(t);
    HapticFeedback.heavyImpact();
    await ConfettiOverlay.show(
      context,
      winnerName: name.toUpperCase(),
      accentColor: PrismColors.magentaFlare,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final safePad = MediaQuery.of(context).padding.top;
    return AmbientParticles(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                  20, safePad + 12, 20, 16),
              color: PrismColors.pitch,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: PrismColors.concrete,
                        border: Border.all(
                            color: PrismColors.dimGray,
                            width: 1),
                      ),
                      child: const Icon(Icons.close,
                          color: PrismColors.ghostWhite,
                          size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'CREATE TOURNAMENT',
                    style: PrismText.hero(
                            color: PrismColors.ghostWhite)
                        .copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('NAME'),
                    const SizedBox(height: 8),
                    _inputField(_nameCtrl,
                        'Tournament name...'),
                    const SizedBox(height: 20),
                    _sectionLabel('SPORT'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _sports.map((s) {
                        return PrismFilterChip(
                          label: s,
                          isSelected: _sport == s,
                          accentColor:
                              PrismColors.sportAccent(s),
                          onTap: () =>
                              setState(() => _sport = s),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel('FORMAT'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _formats.map((f) {
                        return PrismFilterChip(
                          label: f.toUpperCase(),
                          isSelected: _format == f,
                          accentColor:
                              PrismColors.cyanBlitz,
                          onTap: () =>
                              setState(() => _format = f),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel('MAX TEAMS'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [4, 8, 16, 32].map((n) {
                        return PrismFilterChip(
                          label: '$n',
                          isSelected: _maxTeams == n,
                          accentColor:
                              PrismColors.amberShock,
                          onTap: () => setState(
                              () => _maxTeams = n),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel('PRIZE POOL (OPTIONAL)'),
                    const SizedBox(height: 8),
                    _inputField(
                        _prizeCtrl, 'e.g.  ₹5000 cash prize'),
                    const SizedBox(height: 40),
                    VoltButton(
                      label: 'DEPLOY TOURNAMENT ⚡',
                      accentColor:
                          PrismColors.magentaFlare,
                      fullWidth: true,
                      height: 52,
                      onTap: _create,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: PrismText.label(
                color: PrismColors.steelGray)
            .copyWith(fontSize: 10),
      );

  Widget _inputField(
      TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: PrismColors.concrete,
        border: Border.all(
            color: PrismColors.dimGray, width: 1),
      ),
      child: TextField(
        controller: ctrl,
        style: PrismText.body(
            color: PrismColors.ghostWhite),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          hintText: hint,
          hintStyle:
              PrismText.body(color: PrismColors.dimGray),
        ),
      ),
    );
  }
}
