import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/volt_button.dart';
import '../../../core/widgets/profile_orb.dart';
import '../../../core/widgets/stat_counter.dart';
import '../../../core/widgets/ground_hologram.dart';
import '../../../core/widgets/ambient_particles.dart';
import '../../../core/widgets/prism_widgets.dart';
import '../../../models/team_request.dart';
import '../../../models/user_stats.dart';
import '../../../services/user_profile_service.dart';
import 'team_chat_screen.dart';
import 'team_creation_modal.dart';

/// PRISM Football Hub — the main sports coordination screen.
///
/// Layout:
/// 1. Hero Header (animated mesh + timer)
/// 2. Personal Energy Badge
/// 3. Ground Hologram pair (Sand / Hard)
/// 4. Quick Action Bar
class FootballScreen extends StatefulWidget {
  const FootballScreen({Key? key}) : super(key: key);

  @override
  State<FootballScreen> createState() => _FootballScreenState();
}

class _FootballScreenState extends State<FootballScreen>
    with TickerProviderStateMixin {
  List<TeamRequest> _teamRequests = [];

  // ── Current user (sourced from UserProfileService) ───────────────────────
  UserStats get _currentUser => UserProfileService.instance.profile;

  // ── Match timer ──────────────────────────────────────────────────────────
  bool _timerRunning = false;
  int _elapsedSeconds = 0;
  Timer? _mainTimer;

  // ── Team membership ──────────────────────────────────────────────────────
  String? _currentJoinedTeamId;
  final Map<String, List<_ChatMessage>> _teamChats = {};
  Timer? _expiryTimer;
  final Map<String, DateTime> _teamCreatedAt = {};

  // ── Animation controllers ────────────────────────────────────────────────
  late final AnimationController _headerPulseCtrl;
  late final AnimationController _meshCtrl;

  // ── UI state ─────────────────────────────────────────────────────────────
  double _badgeScale = 1.0;

  @override
  void initState() {
    super.initState();
    // Listen to profile changes so energy badge stays in sync
    UserProfileService.instance.addListener(_onProfileChanged);

    _headerPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _meshCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _startExpiryTimer();
  }

  @override
  void dispose() {
    UserProfileService.instance.removeListener(_onProfileChanged);
    _mainTimer?.cancel();
    _expiryTimer?.cancel();
    _headerPulseCtrl.dispose();
    _meshCtrl.dispose();
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  void _startExpiryTimer() {
    _expiryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      setState(() {
        _teamRequests.removeWhere((req) {
          final age = now.difference(req.createdAt);
          return age.inMinutes >= 30;
        });
        if (_currentJoinedTeamId != null) {
          final created = _teamCreatedAt[_currentJoinedTeamId];
          if (created != null &&
              now.difference(created).inMinutes >= 30) {
            _currentJoinedTeamId = null;
          }
        }
      });
    });
  }

  // ── Timer controls ────────────────────────────────────────────────────────

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    if (_timerRunning) {
      _mainTimer?.cancel();
      _mainTimer = null;
      setState(() => _timerRunning = false);
    } else {
      if (_elapsedSeconds >= 600) {
        setState(() => _elapsedSeconds = 0);
      }
      setState(() => _timerRunning = true);
      _mainTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() {
          if (_elapsedSeconds >= 599) {
            _elapsedSeconds = 600;
            _timerRunning = false;
            _mainTimer?.cancel();
            _mainTimer = null;
          } else {
            _elapsedSeconds++;
          }
        });
      });
    }
  }

  String get _timerDisplay {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Team logic ────────────────────────────────────────────────────────────

  void _joinTeam(TeamRequest req) {
    if (_currentJoinedTeamId != null) {
      _showToast('Already in a team — leave first', PrismColors.amberShock);
      return;
    }
    setState(() {
      _currentJoinedTeamId = req.id;
      _teamChats.putIfAbsent(req.id, () => []);
      _teamCreatedAt[req.id] = req.createdAt;

      final idx = _teamRequests.indexWhere((r) => r.id == req.id);
      if (idx >= 0) {
        final r = _teamRequests[idx];
        _teamRequests[idx] = TeamRequest(
          id: r.id,
          sport: r.sport,
          groundNumber: r.groundNumber,
          playersNeeded: r.playersNeeded,
          currentPlayers: r.currentPlayers + 1,
          playerIds: [...r.playerIds, _currentUser.userId],
          creatorId: r.creatorId,
          createdAt: r.createdAt,
          status: r.status,
        );
      }
    });
    _showToast('Joined team!', PrismColors.voltGreen);
  }

  void _leaveTeam() {
    setState(() => _currentJoinedTeamId = null);
    _showToast('Left the team', PrismColors.steelGray);
  }

  void _createTeam(int ground, int needed) {
    final req = TeamRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sport: 'Football',
      groundNumber: ground,
      playersNeeded: needed,
      currentPlayers: 1,
      playerIds: [_currentUser.userId],
      creatorId: _currentUser.userId,
      createdAt: DateTime.now(),
      status: 'active',
    );
    setState(() {
      _teamRequests.insert(0, req);
      _currentJoinedTeamId = req.id;
      _teamChats[req.id] = [];
      _teamCreatedAt[req.id] = req.createdAt;
    });
    _showToast('Team created! ⚡', PrismColors.voltGreen);
  }

  void _showToast(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: PrismText.subtitle(color: color)),
        backgroundColor: PrismColors.pitch,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Ground requests helpers ───────────────────────────────────────────────

  List<TeamRequest> _requestsForGround(int ground) =>
      _teamRequests.where((r) => r.groundNumber == ground).toList();

  int _activePlayersOnGround(int ground) {
    return _requestsForGround(ground)
        .fold(0, (sum, r) => sum + r.currentPlayers);
  }

  bool get _isInSandGround =>
      _currentJoinedTeamId != null &&
      _teamRequests.any((r) =>
          r.id == _currentJoinedTeamId && r.groundNumber == 1);

  bool get _isInHardGround =>
      _currentJoinedTeamId != null &&
      _teamRequests.any((r) =>
          r.id == _currentJoinedTeamId && r.groundNumber == 2);

  int get _activePlayers =>
      _teamRequests.fold(0, (s, r) => s + r.currentPlayers);

  // ── UI builders ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AmbientParticles(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          color: PrismColors.voltGreen,
          backgroundColor: PrismColors.pitch,
          onRefresh: () async =>
              setState(() => _teamRequests = [..._teamRequests]),
          child: CustomScrollView(
            slivers: [
              // ── Hero Header ──────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeroHeader()),
              // ── Personal badge ───────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: GestureDetector(
                    onTapDown: (_) =>
                        setState(() => _badgeScale = 0.97),
                    onTapUp: (_) =>
                        setState(() => _badgeScale = 1.0),
                    onTapCancel: () =>
                        setState(() => _badgeScale = 1.0),
                    child: AnimatedScale(
                      scale: _badgeScale,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOutBack,
                      child: _buildEnergyBadge(),
                    ),
                  )
                      .animate()
                      .fadeIn(
                          duration: 300.ms,
                          curve: Curves.easeOut)
                      .slideY(
                          begin: 0.08,
                          end: 0,
                          curve: Curves.easeOutCubic),
                ),
              ),
              // ── Ground holograms ─────────────────────────────────────────
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildGroundHolograms()
                      .animate(delay: 60.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0),
                ),
              ),
              // ── Active requests ──────────────────────────────────────────
              if (_teamRequests.isNotEmpty)
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'LOOKING FOR PLAYERS',
                      style: PrismText.label(),
                    ),
                  ),
                ),
              if (_teamRequests.isNotEmpty)
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildTeamRequestCard(
                              _teamRequests[i], i)
                          .animate(
                              delay:
                                  Duration(milliseconds: i * 60))
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.08, end: 0),
                      childCount: _teamRequests.length,
                    ),
                  ),
                ),
              // Bottom padding for action bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        // ── Quick action bar ─────────────────────────────────────────────
        bottomSheet: _buildActionBar(),
      ),
    );
  }

  // ── Hero Header ──────────────────────────────────────────────────────────

  Widget _buildHeroHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_headerPulseCtrl, _meshCtrl]),
      builder: (_, __) {
        return Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PrismColors.voltGreen.withOpacity(0.12),
                PrismColors.abyss,
                PrismColors.cyanBlitz.withOpacity(0.06),
              ],
              stops: [
                0.0,
                0.5 + _meshCtrl.value * 0.2,
                1.0,
              ],
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            bottom: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Sport name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'FOOTBALL',
                      style: PrismText.hero(color: PrismColors.ghostWhite)
                          .copyWith(fontSize: 38),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _activePlayers > 0
                                ? PrismColors.voltGreen
                                : PrismColors.dimGray,
                            shape: BoxShape.circle,
                            boxShadow: _activePlayers > 0
                                ? [
                                    BoxShadow(
                                      color: PrismColors.voltGreen
                                          .withOpacity(0.6),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _activePlayers > 0
                              ? '$_activePlayers ACTIVE NOW'
                              : 'NO ACTIVE TEAMS',
                          style: PrismText.label(
                            color: _activePlayers > 0
                                ? PrismColors.voltGreen
                                : PrismColors.dimGray,
                          ).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Timer button
              _buildTimerButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerButton() {
    return GestureDetector(
      onTap: _toggleTimer,
      onLongPress: () {
        setState(() {
          _elapsedSeconds = 0;
          _timerRunning = false;
          _mainTimer?.cancel();
          _mainTimer = null;
        });
        HapticFeedback.heavyImpact();
      },
      child: AnimatedBuilder(
        animation: _headerPulseCtrl,
        builder: (_, __) {
          final isUrgent = _timerRunning && _elapsedSeconds > 540;
          final activeColor = isUrgent
              ? PrismColors.redAlert
              : PrismColors.voltGreen;

          return Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: PrismColors.pitch,
              border: Border.all(
                color: _timerRunning
                    ? activeColor.withOpacity(
                        0.4 + _headerPulseCtrl.value * 0.5)
                    : PrismColors.dimGray,
                width: _timerRunning ? 2 : 1,
              ),
              boxShadow: _timerRunning
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(
                            0.15 + _headerPulseCtrl.value * 0.3),
                        blurRadius:
                            isUrgent ? 24 + _headerPulseCtrl.value * 12 : 20,
                        spreadRadius: isUrgent
                            ? 2 + _headerPulseCtrl.value * 3
                            : 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Digit morph via AnimatedSwitcher
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.75, end: 1.0)
                          .animate(CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOutBack)),
                      child: child,
                    ),
                  ),
                  child: Text(
                    _timerDisplay,
                    key: ValueKey(_elapsedSeconds),
                    style: PrismText.mono(
                      fontSize: isUrgent ? 14 : 15,
                      color: _timerRunning
                          ? activeColor
                          : PrismColors.steelGray,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timerRunning ? 'STOP' : 'START',
                  style: PrismText.label(
                    color: _timerRunning
                        ? activeColor
                        : PrismColors.dimGray,
                  ).copyWith(fontSize: 8),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Personal Energy Badge ─────────────────────────────────────────────────

  Widget _buildEnergyBadge() {
    final vibeColor = _currentUser.getVibeColor();

    return HolographicCard(
      accentColor: vibeColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ProfileOrb(
            name: _currentUser.name,
            photoUrl: _currentUser.photoUrl,
            ringColor: vibeColor,
            isActive: _currentJoinedTeamId != null,
            size: 52,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _currentUser.name.toUpperCase(),
                      style: PrismText.title(
                              color: PrismColors.ghostWhite)
                          .copyWith(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    if (_currentUser.getTopTag().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: vibeColor.withOpacity(0.15),
                          border: Border.all(
                              color: vibeColor.withOpacity(0.5),
                              width: 1),
                        ),
                        child: Text(
                          '⚡ ${_currentUser.getTopTag().toUpperCase()}',
                          style: PrismText.tag(color: vibeColor)
                              .copyWith(fontSize: 9),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser.mainPosition.isEmpty
                      ? 'NO POSITION SET'
                      : _currentUser.mainPosition.toUpperCase(),
                  style: PrismText.label(
                          color: PrismColors.steelGray)
                      .copyWith(
                    fontSize: 10,
                    color: PrismColors.steelGray,
                  ),
                ),
                const SizedBox(height: 6),
                // Tags
                Wrap(
                  spacing: 6,
                  children: _currentUser.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      color: PrismColors.concrete,
                      child: Text(
                        tag.toUpperCase(),
                        style: PrismText.tag(
                                color: PrismColors.steelGray)
                            .copyWith(fontSize: 9),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Stats column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatCounter(
                value: _activePlayers.toDouble(),
                label: 'ACTIVE',
                color: PrismColors.voltGreen,
                numberSize: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Ground Holograms ──────────────────────────────────────────────────────

  Widget _buildGroundHolograms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GROUNDS', style: PrismText.label()),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GroundHologram(
                groundName: 'SAND GROUND',
                accentColor: PrismColors.voltGreen,
                activePlayers: _activePlayersOnGround(1),
                maxPlayers: 12,
                teamCount: _requestsForGround(1).length,
                isUserOnGround: _isInSandGround,
                onTap: () => _showGroundDrawer(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GroundHologram(
                groundName: 'HARD GROUND',
                accentColor: PrismColors.cyanBlitz,
                activePlayers: _activePlayersOnGround(2),
                maxPlayers: 12,
                teamCount: _requestsForGround(2).length,
                isUserOnGround: _isInHardGround,
                onTap: () => _showGroundDrawer(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Team Request Card ─────────────────────────────────────────────────────

  Widget _buildTeamRequestCard(TeamRequest req, int idx) {
    final isJoined = _currentJoinedTeamId == req.id;
    final groundName = req.groundNumber == 1 ? 'SAND GROUND' : 'HARD GROUND';
    final accent = req.groundNumber == 1
        ? PrismColors.voltGreen
        : PrismColors.cyanBlitz;
    final isFull =
        req.currentPlayers >= req.playersNeeded + 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HolographicCard(
        accentColor: accent,
        isLive: isJoined,
        onTap: isJoined
            ? () => _openChat(req)
            : isFull
                ? null
                : () => _joinTeam(req),
        child: Row(
          children: [
            // Ground + players
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 20,
                        color: accent,
                        margin:
                            const EdgeInsets.only(right: 8),
                      ),
                      Text(
                        groundName,
                        style: PrismText.label(color: accent)
                            .copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${req.currentPlayers}',
                        style: PrismText.mono(
                          fontSize: 28,
                          color: PrismColors.ghostWhite,
                        ),
                      ),
                      Text(
                        ' / ${req.playersNeeded + 1} PLAYERS',
                        style: PrismText.subtitle(
                            color: PrismColors.steelGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Age
                  Text(
                    _ageLabel(req.createdAt),
                    style: PrismText.caption(
                        color: PrismColors.dimGray),
                  ),
                ],
              ),
            ),
            // Action button
            SizedBox(
              width: 110,
              child: isJoined
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VoltButton(
                          label: 'CHAT',
                          variant: VoltButtonVariant.primary,
                          accentColor: accent,
                          height: 40,
                          icon: Icons.chat_bubble_outline,
                          onTap: () => _openChat(req),
                        ),
                        const SizedBox(height: 6),
                        VoltButton(
                          label: 'LEAVE',
                          variant: VoltButtonVariant.ghost,
                          accentColor: PrismColors.steelGray,
                          height: 36,
                          onTap: _leaveTeam,
                        ),
                      ],
                    )
                  : VoltButton(
                      label: isFull ? 'FULL' : 'JOIN ⚡',
                      variant: VoltButtonVariant.ghost,
                      accentColor: accent,
                      height: 44,
                      onTap: isFull ? null : () => _joinTeam(req),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _ageLabel(DateTime createdAt) {
    final age = DateTime.now().difference(createdAt);
    if (age.inMinutes == 0) return 'JUST NOW';
    if (age.inMinutes == 1) return '1 MIN AGO';
    return '${age.inMinutes} MINS AGO · ${30 - age.inMinutes}m LEFT';
  }

  // ── Action Bar ────────────────────────────────────────────────────────────

  Widget _buildActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: PrismColors.pitch.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: PrismColors.concrete,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: PrismColors.voltGreen.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: VoltButton(
              label: 'CREATE TEAM',
              variant: VoltButtonVariant.primary,
              accentColor: PrismColors.voltGreen,
              icon: Icons.flash_on,
              fullWidth: true,
              onTap: _showCreateTeamModal,
            ),
          ),
          const SizedBox(width: 12),
          if (_currentJoinedTeamId != null)
            Expanded(
              child: VoltButton(
                label: 'OPEN CHAT',
                variant: VoltButtonVariant.ghost,
                accentColor: PrismColors.cyanBlitz,
                icon: Icons.chat_bubble_outline,
                fullWidth: true,
                onTap: () {
                  final req = _teamRequests.firstWhere(
                    (r) => r.id == _currentJoinedTeamId,
                    orElse: () => _teamRequests.first,
                  );
                  _openChat(req);
                },
              ),
            ),
        ],
      ),
    );
  }

  // ── Modals & navigation ───────────────────────────────────────────────────

  void _showCreateTeamModal() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.85),
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => TeamCreationModal(
          onTeamCreated: (ground, needed) {
            Navigator.pop(context);
            _createTeam(ground, needed);
          },
        ),
        transitionsBuilder: (_, anim, __, child) => ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0)
              .animate(CurvedAnimation(
                  parent: anim, curve: Curves.easeOutBack)),
          child: FadeTransition(opacity: anim, child: child),
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  void _openChat(TeamRequest req) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeamChatScreen(
          teamRequest: req,
          currentUser: _currentUser,
          initialMessages: _teamChats[req.id] ?? [],
          onMessageSent: (msg) {
            setState(() {
              _teamChats.putIfAbsent(req.id, () => []);
              _teamChats[req.id]!.add(_ChatMessage(
                senderId: _currentUser.userId,
                senderName: _currentUser.name,
                text: msg,
                timestamp: DateTime.now(),
              ));
            });
          },
        ),
      ),
    );
  }

  void _showGroundDrawer(int ground) {
    final requests = _requestsForGround(ground);
    final groundName =
        ground == 1 ? 'SAND GROUND' : 'HARD GROUND';
    final accent =
        ground == 1 ? PrismColors.voltGreen : PrismColors.cyanBlitz;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.65,
        ),
        decoration: BoxDecoration(
          color: PrismColors.pitch,
          border: Border(
            top: BorderSide(color: accent.withOpacity(0.4), width: 2),
            left: BorderSide(color: accent.withOpacity(0.15), width: 1),
            right: BorderSide(color: accent.withOpacity(0.15), width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 3,
                color: PrismColors.concrete,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(groundName, style: PrismText.title(color: accent)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    color: accent.withOpacity(0.12),
                    child: Text(
                      '${requests.length} TEAM${requests.length != 1 ? 'S' : ''}',
                      style: PrismText.tag(color: accent),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: PrismColors.concrete),
            if (requests.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Text('⚽',
                          style: const TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      Text(
                        'NO ACTIVE TEAMS',
                        style: PrismText.label(
                            color: PrismColors.dimGray),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create the first team request',
                        style: PrismText.body(),
                      ),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, i) =>
                      _buildTeamRequestCard(requests[i], i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Local chat message model ──────────────────────────────────────────────────

class _ChatMessage {
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  _ChatMessage({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });
}
