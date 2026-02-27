import 'dart:async';
import 'package:flutter/material.dart';
import '../models/team_request.dart';
import '../models/user_stats.dart';

/// Football screen displaying active games and team requests.
/// 
/// This screen shows:
/// - Active ongoing games
/// - Team requests looking for players
/// - Option to create a new team request
class FootballScreen extends StatefulWidget {
  const FootballScreen({Key? key}) : super(key: key);

  @override
  State<FootballScreen> createState() => _FootballScreenState();
}

class _FootballScreenState extends State<FootballScreen> {
  /// Mock data for team requests
  late List<TeamRequest> _teamRequests;

  /// Current logged-in user's stats (mock).
  late UserStats _currentUser;

  /// Selected ground for creating new team request
  int _selectedGround = 1;

  /// Selected player count for creating new team request
  int _selectedPlayers = 3;

  /// Loading state flag
  bool _isLoading = false;

  // ── Standalone match timer ────────────────────────────────────────────────
  bool _timerRunning = false;
  int _elapsedSeconds = 0;
  Timer? _mainTimer;

  // ── Team membership, chat & auto-dissolution ─────────────────────────────
  String? _currentJoinedTeamId;
  final Map<String, List<_ChatMessage>> _teamChats = {};
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    _currentUser = const UserStats(
      userId: 'current_user_123',
      name: 'Rahul',
      photoUrl: '',
      tags: ['Sledger', 'Sweaty', 'Clutch'],
      mainPosition: 'Striker',
      favoriteGround: 'Sand Ground',
      rollNumber: '24BCE0740',
    );

    _teamRequests = [
      TeamRequest(
        id: 'demo1',
        sport: 'Football',
        groundNumber: 1, // Sand Ground
        playersNeeded: 6,
        currentPlayers: 3,
        playerIds: ['demo_user1', 'demo_user2', 'demo_user3'],
        creatorId: 'demo_creator',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        status: 'active',
      ),
    ];
    _startExpiryTimer();
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    _expiryTimer?.cancel();
    super.dispose();
  }

  /// Refreshes the data (mock implementation)
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  /// Shows bottom sheet to create a new team request.
  ///
  /// Uses [StatefulBuilder] so modal UI state updates independently from the
  /// parent, fixing the issue where dropdown selections appeared frozen.
  void _showCreateTeamSheet() {
    int localGround = _selectedGround;
    int localPlayers = _selectedPlayers;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF7CFC00).withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF7CFC00), Color(0xFF9AFF00)],
                        ).createShader(bounds),
                        child: Text(
                          'FIND PLAYERS',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Ground dropdown
                  Text(
                    'SELECT GROUND',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      border: Border.all(
                        color: const Color(0xFF7CFC00).withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<int>(
                      value: localGround,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      dropdownColor: const Color(0xFF121212),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Sand Ground'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Hard Ground'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => localGround = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Players dropdown
                  Text(
                    'PLAYERS NEEDED',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      border: Border.all(
                        color: const Color(0xFF7CFC00).withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<int>(
                      value: localPlayers,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      dropdownColor: const Color(0xFF121212),
                      items: List.generate(
                        5,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            '${index + 1} ${index + 1 == 1 ? 'Player' : 'Players'}',
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => localPlayers = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Create button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedGround = localGround;
                          _selectedPlayers = localPlayers;
                          _teamRequests.insert(
                            0,
                            TeamRequest(
                              id: DateTime.now().toString(),
                              sport: 'Football',
                              groundNumber: localGround,
                              playersNeeded: localPlayers,
                              currentPlayers: 1,
                              playerIds: ['currentUser'],
                              creatorId: 'currentUser',
                              createdAt: DateTime.now(),
                              status: 'active',
                            ),
                          );
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Team request created successfully!',
                              style: TextStyle(color: Color(0xFF7CFC00), fontWeight: FontWeight.w700),
                            ),
                            backgroundColor: Colors.black.withOpacity(0.80),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: const Color(0xFF7CFC00).withOpacity(0.45)),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text(
                        'CREATE TEAM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Formats elapsed seconds into MM:SS display string (max 10:00).
  String _formatTime(int totalSeconds) {
    final clamped = totalSeconds.clamp(0, 600);
    final m = (clamped ~/ 60).toString().padLeft(2, '0');
    final s = (clamped % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Starts the standalone count-up timer.
  /// Prevents duplicate timers; auto-stops at 600 s (10:00).
  void _startMainTimer() {
    if (_mainTimer != null) return;
    if (_elapsedSeconds >= 600) return;
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Full time — 10 minutes completed',
                style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w700),
              ),
              backgroundColor: Colors.black.withOpacity(0.80),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade700.withOpacity(0.5)),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          _elapsedSeconds++;
        }
      });
    });
  }

  /// Stops the standalone timer with an optional golden-goal notification.
  void _stopMainTimer({bool golden = false}) {
    _mainTimer?.cancel();
    _mainTimer = null;
    setState(() => _timerRunning = false);
    if (golden) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Match ended — Golden goal',
            style: TextStyle(color: Color(0xFF7CFC00), fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.black.withOpacity(0.80),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: const Color(0xFF7CFC00).withOpacity(0.45)),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Resets the standalone timer to 00:00.
  void _resetMainTimer() {
    _mainTimer?.cancel();
    _mainTimer = null;
    setState(() {
      _timerRunning = false;
      _elapsedSeconds = 0;
    });
  }

  /// Joins a team request, enforcing single-team restriction.
  void _joinTeam(TeamRequest req) {
    if (_currentJoinedTeamId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "You're already in a team. Leave current team first.",
            style: TextStyle(color: Colors.orange.shade400, fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.black.withOpacity(0.80),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.shade800.withOpacity(0.5)),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _currentJoinedTeamId = req.id;
      _teamChats.putIfAbsent(req.id, () => []);
    });
    // Auto-open team chat as a welcome gesture
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showTeamChat(req);
    });
  }

  /// Leaves the currently joined team.
  void _leaveTeam() {
    setState(() {
      _currentJoinedTeamId = null;
    });
  }

  /// Starts the 30-minute auto-dissolution background timer.
  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      _checkExpiredTeams();
    });
  }

  /// Removes team requests older than 30 minutes and notifies the user.
  void _checkExpiredTeams() {
    final now = DateTime.now();
    final expiredIds = _teamRequests
        .where((r) => now.difference(r.createdAt).inMinutes >= 30)
        .map((r) => r.id)
        .toList();
    if (expiredIds.isEmpty) return;
    final wasInExpired = _currentJoinedTeamId != null &&
        expiredIds.contains(_currentJoinedTeamId);
    setState(() {
      _teamRequests.removeWhere((r) => expiredIds.contains(r.id));
      if (wasInExpired) _currentJoinedTeamId = null;
    });
    if (wasInExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Team disbanded after 30 minutes',
            style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.black.withOpacity(0.80),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade700.withOpacity(0.5)),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Returns requests filtered and sorted for the given ground numbers.
  List<TeamRequest> _requestsForGround(List<int> numbers) {
    return _teamRequests
        .where((r) => numbers.contains(r.groundNumber))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
  }

  /// Opens a [_GroundRequestsSheet] directly from the main screen.
  void _openGroundSheet(String groundLabel, List<TeamRequest> requests) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GroundRequestsSheet(
        groundLabel: groundLabel,
        requests: requests,
        currentJoinedTeamId: _currentJoinedTeamId,
        currentUserName: _currentUser.name,
        onJoin: (req) {
          _joinTeam(req);
          Navigator.pop(context);
        },
        onLeave: () {
          _leaveTeam();
          Navigator.pop(context);
        },
        onOpenChat: _showTeamChat,
      ),
    );
  }

  /// Opens the ephemeral team chat sheet for [req].
  void _showTeamChat(TeamRequest req) {
    _teamChats.putIfAbsent(req.id, () => []);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TeamChatSheet(
        request: req,
        currentUserId: _currentUser.userId,
        currentUserName: _currentUser.name,
        messages: _teamChats[req.id]!,
        onSend: (msg) {
          setState(() {
            _teamChats.putIfAbsent(req.id, () => []).add(msg);
          });
        },
      ),
    );
  }

  /// Opens the standalone timer bottom sheet.
  void _showSimpleTimerSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SimpleTimerSheet(
        getElapsedSeconds: () => _elapsedSeconds,
        isRunning: () => _timerRunning,
        onStart: _startMainTimer,
        onStop: () => _stopMainTimer(golden: true),
        onReset: _resetMainTimer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('FOOTBALL'),
        actions: [
          // Standalone match timer
          if (_timerRunning || _elapsedSeconds > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Text(
                  _formatTime(_elapsedSeconds),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _timerRunning
                        ? theme.colorScheme.primary
                        : Colors.white54,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.timer_outlined,
              size: 22,
              color: _timerRunning
                  ? theme.colorScheme.primary
                  : Colors.white.withOpacity(0.7),
            ),
            tooltip: 'Match Timer',
            onPressed: _showSimpleTimerSheet,
          ),
          IconButton(
            icon: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshData,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'find_players_fab',
        onPressed: _showCreateTeamSheet,
        icon: const Icon(Icons.add),
        label: const Text('FIND PLAYERS'),
      ),
      body: _buildListView(theme),
    );
  }

  /// Builds the main list view with personal stats and ground cards.
  Widget _buildListView(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    final sandRequests = _requestsForGround([1]);
    final hardRequests = _requestsForGround([2]);

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Personal stats card ─────────────────────────────────────────
          _buildPersonalStatsCard(theme),
          const SizedBox(height: 24),

          // ── FIND A TEAM section header ──────────────────────────────────
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF7CFC00), Color(0xFF9AFF00)],
            ).createShader(bounds),
            child: Text(
              'FIND A TEAM',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a ground to see active team requests',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
          ),
          const SizedBox(height: 12),

          // ── Ground cards grid ───────────────────────────────────────────
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
            children: [
              _GroundCard(
                label: 'Sand Ground',
                isSand: true,
                requests: sandRequests,
                screenWidth: size.width,
                currentJoinedTeamId: _currentJoinedTeamId,
                currentUserInitial: _currentUser.name.isNotEmpty
                    ? _currentUser.name[0].toUpperCase()
                    : '?',
                currentUserColor: _currentUser.getVibeColor(),
                // Disable tap when user is already on this ground
                onTap: sandRequests.isEmpty ||
                        sandRequests.any((r) => r.id == _currentJoinedTeamId)
                    ? null
                    : () => _openGroundSheet('Sand Ground', sandRequests),
              ),
              _GroundCard(
                label: 'Hard Ground',
                isSand: false,
                requests: hardRequests,
                screenWidth: size.width,
                currentJoinedTeamId: _currentJoinedTeamId,
                currentUserInitial: _currentUser.name.isNotEmpty
                    ? _currentUser.name[0].toUpperCase()
                    : '?',
                currentUserColor: _currentUser.getVibeColor(),
                onTap: hardRequests.isEmpty ||
                        hardRequests.any((r) => r.id == _currentJoinedTeamId)
                    ? null
                    : () => _openGroundSheet('Hard Ground', hardRequests),
              ),
            ],
          ),

          // ── Joined-team action bar ─────────────────────────────────────
          if (_currentJoinedTeamId != null) ...[
            const SizedBox(height: 16),
            Builder(builder: (context) {
              final joinedReq = _teamRequests.firstWhere(
                (r) => r.id == _currentJoinedTeamId,
                orElse: () => _teamRequests.first,
              );
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1F0D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF7CFC00).withOpacity(0.35),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Color(0xFF7CFC00), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'YOU\'RE IN A TEAM',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7CFC00),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Open Chat
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1C3A6E),
                                  Color(0xFF0D5E6E)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _showTeamChat(joinedReq),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16,
                                  color: Colors.white),
                              label: const Text(
                                'TEAM CHAT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Leave Team
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _leaveTeam,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade400,
                              side: BorderSide(
                                  color: Colors.red.shade900
                                      .withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.exit_to_app,
                                size: 16, color: Colors.red.shade400),
                            label: Text(
                              'LEAVE TEAM',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ── Personal Stats Card ────────────────────────────────────────────────────

  Widget _buildPersonalStatsCard(ThemeData theme) {
    final user = _currentUser;
    final vibeColor = user.getVibeColor();

    return GestureDetector(
      onTap: () => _showFullStatsSheet(user),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: vibeColor.withOpacity(0.55), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: vibeColor.withOpacity(0.18),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: vibeColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: vibeColor.withOpacity(0.35),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: const Color(0xFF2A2A2A),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: vibeColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    user.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Roll number
                  Text(
                    user.rollNumber.isNotEmpty
                        ? user.rollNumber.toUpperCase()
                        : user.mainPosition.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white60,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tags as pills
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: user.tags.take(3).map((tag) {
                      final c = tagColor(tag);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: c.withOpacity(0.45), width: 1),
                        ),
                        child: Text(
                          '#${tag.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: c,
                            letterSpacing: 0.8,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Expand icon
            Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }

  /// Opens the full-detail stats bottom sheet.
  void _showFullStatsSheet(UserStats user) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FullStatsSheet(
        user: user,
        onSave: (name, tags) {
          setState(() {
            _currentUser = _currentUser.copyWith(
              name: name.isEmpty ? _currentUser.name : name,
              tags: tags,
            );
          });
        },
      ),
    );
  }
}

/// All available player tags for selection.
const List<String> _kFootballTags = [
  'Team Player', 'Clutch', 'Early Bird', 'Consistent', 'No Cap',
  'Captain', 'Built Different', 'Carrying', 'Chill',
  'Sweaty', 'Ball Hog', 'Rage Quitter', 'Excuse Maker',
  'Sledger', 'Bad Mouth', 'Toxic', 'Cooked',
  'Late', 'Mid', 'NPC',
];

/// Full-detail player stats bottom sheet (with edit support).
class _FullStatsSheet extends StatefulWidget {
  const _FullStatsSheet({required this.user, required this.onSave});

  final UserStats user;
  final void Function(String name, List<String> tags) onSave;

  @override
  State<_FullStatsSheet> createState() => _FullStatsSheetState();
}

class _FullStatsSheetState extends State<_FullStatsSheet> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _selectedTags = List<String>.from(widget.user.tags);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.onSave(
      _nameController.text.trim(),
      List<String>.from(_selectedTags),
    );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vibeColor = widget.user.getVibeColor();
    final rollLabel = widget.user.rollNumber.isNotEmpty
        ? widget.user.rollNumber.toUpperCase()
        : widget.user.mainPosition.toUpperCase();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: vibeColor.withOpacity(0.30), width: 1.5),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: vibeColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: vibeColor.withOpacity(0.30),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF2A2A2A),
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: vibeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing
                              ? 'EDIT PROFILE'
                              : _nameController.text.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            rollLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white60,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isEditing)
                    TextButton(
                      onPressed: _saveChanges,
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          color: Color(0xFF7CFC00),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      tooltip: 'Edit profile',
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white38,
                        size: 22,
                      ),
                    ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white38),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white12),
              const SizedBox(height: 20),

              // ── EDIT MODE ────────────────────────────────────────────────
              if (_isEditing) ...[
                Text(
                  'DISPLAY NAME',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0A0A0A),
                    hintText: 'Enter display name',
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF7CFC00),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'CHOOSE TAGS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to select / deselect  •  max 3  (${_selectedTags.length}/3 selected)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _selectedTags.length >= 3
                        ? const Color(0xFF7CFC00)
                        : Colors.white24,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _kFootballTags.map((tag) {
                    final selected = _selectedTags.contains(tag);
                    final limitReached = _selectedTags.length >= 3;
                    final disabled = !selected && limitReached;
                    final c = tagColor(tag);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedTags.remove(tag);
                          } else if (_selectedTags.length < 3) {
                            _selectedTags.add(tag);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? c.withOpacity(0.22)
                              : Colors.white.withOpacity(disabled ? 0.02 : 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? c : (disabled ? Colors.white.withOpacity(0.06) : Colors.white12),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selected)
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Icon(Icons.check,
                                    size: 12, color: c),
                              ),
                            Text(
                              '#${tag.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: selected ? c : (disabled ? Colors.white12 : Colors.white38),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                // Save button at the bottom of edit mode
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CFC00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'SAVE CHANGES',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // ── VIEW MODE ──────────────────────────────────────────────

                // Tags section
                Text(
                  'PLAYER TAGS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _selectedTags.map((tag) {
                    final c = tagColor(tag);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: c.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: c.withOpacity(0.45), width: 1.5),
                      ),
                      child: Text(
                        '#${tag.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: c,
                          letterSpacing: 0.8,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// A large ground card showing a painted field with team request deck overlay.
///
/// Converted to [StatefulWidget] to drive the pulsing avatar animation when
/// the current user has joined a team on this ground.
class _GroundCard extends StatefulWidget {
  const _GroundCard({
    required this.label,
    required this.isSand,
    required this.requests,
    required this.screenWidth,
    required this.onTap,
    required this.currentJoinedTeamId,
    required this.currentUserInitial,
    required this.currentUserColor,
  });

  final String label;
  final bool isSand;
  final List<TeamRequest> requests;
  final double screenWidth;
  final VoidCallback? onTap;
  final String? currentJoinedTeamId;
  final String currentUserInitial;
  final Color currentUserColor;

  @override
  State<_GroundCard> createState() => _GroundCardState();
}

class _GroundCardState extends State<_GroundCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get _isUserOnThisGround {
    if (widget.currentJoinedTeamId == null) return false;
    return widget.requests.any((r) => r.id == widget.currentJoinedTeamId);
  }

  Color get _surfaceColor =>
      widget.isSand ? const Color(0xFF1A1306) : const Color(0xFF060D1A);

  Color get _fieldColor => widget.isSand
      ? const Color(0xFFC8A96E).withOpacity(0.22)
      : const Color(0xFF4A90D9).withOpacity(0.16);

  Color get _accentColor =>
      widget.isSand ? const Color(0xFFD4A847) : const Color(0xFF4A90D9);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRequests = widget.requests.isNotEmpty;
    final isUserHere = _isUserOnThisGround;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUserHere
                ? const Color(0xFF7CFC00).withOpacity(0.7)
                : hasRequests
                    ? _accentColor.withOpacity(0.55)
                    : Colors.white.withOpacity(0.07),
            width: (isUserHere || hasRequests) ? 1.5 : 1,
          ),
          boxShadow: isUserHere
              ? [
                  BoxShadow(
                    color: const Color(0xFF7CFC00).withOpacity(0.28),
                    blurRadius: 28,
                    spreadRadius: 3,
                  ),
                ]
              : hasRequests
                  ? [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.22),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ]
                  : const [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            children: [
              // Drawn field background
              Positioned.fill(
                child: CustomPaint(
                  painter: _GroundFieldPainter(
                    fieldColor: _fieldColor,
                    lineColor: _accentColor.withOpacity(0.28),
                  ),
                ),
              ),
              // Dim overlay when empty
              if (!hasRequests)
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.48)),
                ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar row — only visible when user has joined here
                    if (isUserHere)
                      Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, __) => Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF7CFC00),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7CFC00)
                                      .withOpacity(_pulseAnim.value * 0.65),
                                  blurRadius: 14,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: const Color(0xFF122012),
                              child: Text(
                                widget.currentUserInitial,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: widget.currentUserColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 4),
                    const SizedBox(height: 10),
                    // Ground name
                    Text(
                      widget.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: hasRequests ? Colors.white : Colors.white38,
                        height: 1.1,
                      ),
                    ),
                    const Spacer(),
                    // Deck or empty state
                    if (hasRequests)
                      _buildDeck(theme)
                    else
                      _buildEmptyState(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeck(ThemeData theme) {
    final count = widget.requests.length;
    final deckDepth = count.clamp(0, 3);

    return SizedBox(
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < deckDepth; i++)
            Positioned(
              bottom: i * 13.0,
              left: (deckDepth - i - 1) * 7.0,
              right: -(deckDepth - i - 1) * 7.0,
              child: Transform.rotate(
                angle: (i - deckDepth / 2) * 0.09,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF1C1C1C).withOpacity(0.92 - i * 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accentColor.withOpacity(0.28 - i * 0.06),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 74,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _accentColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.groups, color: _accentColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$count ${count == 1 ? 'request' : 'requests'}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Tap to view',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _accentColor.withOpacity(0.65),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: _accentColor.withOpacity(0.6),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -8,
            right: -6,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.sports_soccer_outlined,
            size: 30, color: Colors.white24),
        const SizedBox(height: 8),
        Text(
          'No teams\nlooking',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white30,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// Paints a simplified top-down football field inside [_GroundCard].
class _GroundFieldPainter extends CustomPainter {
  const _GroundFieldPainter({
    required this.fieldColor,
    required this.lineColor,
  });

  final Color fieldColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = fieldColor
      ..style = PaintingStyle.fill;
    final line = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Background tint
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fill);

    // Field boundary
    final fr = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.22,
      size.width * 0.84,
      size.height * 0.58,
    );
    canvas.drawRect(fr, line);

    // Centre line
    canvas.drawLine(
        Offset(fr.center.dx, fr.top), Offset(fr.center.dx, fr.bottom), line);

    // Centre circle
    canvas.drawCircle(fr.center, fr.width * 0.16, line);

    // Goal boxes
    final goalW = fr.width * 0.18;
    final goalH = fr.height * 0.36;
    final goalTop = fr.top + (fr.height - goalH) / 2;
    canvas.drawRect(
        Rect.fromLTWH(fr.left, goalTop, goalW, goalH), line);
    canvas.drawRect(
        Rect.fromLTWH(fr.right - goalW, goalTop, goalW, goalH), line);
  }

  @override
  bool shouldRepaint(_GroundFieldPainter old) =>
      old.fieldColor != fieldColor || old.lineColor != lineColor;
}

/// Bottom sheet listing all requests for a chosen ground, sorted oldest-first.
class _GroundRequestsSheet extends StatelessWidget {
  const _GroundRequestsSheet({
    required this.groundLabel,
    required this.requests,
    required this.currentJoinedTeamId,
    required this.currentUserName,
    required this.onJoin,
    required this.onLeave,
    required this.onOpenChat,
  });

  final String groundLabel;
  final List<TeamRequest> requests;
  final String? currentJoinedTeamId;
  final String currentUserName;
  final ValueChanged<TeamRequest> onJoin;
  final VoidCallback onLeave;
  final ValueChanged<TeamRequest> onOpenChat;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Sheet header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groundLabel.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF4A90D9).withOpacity(0.65),
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${requests.length} '
                            '${requests.length == 1 ? 'Team' : 'Teams'} Looking',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.white.withOpacity(0.06)),
              // Request cards
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    final isJoined = req.id == currentJoinedTeamId;
                    final hasJoinedAny = currentJoinedTeamId != null;
                    // minutes left before 30-min dissolution
                    final ageMin =
                        DateTime.now().difference(req.createdAt).inMinutes;
                    final minsLeft = (30 - ageMin).clamp(0, 30);
                    return _RequestListCard(
                      request: req,
                      groundLabel: groundLabel,
                      timeAgo: _timeAgo(req.createdAt),
                      isUrgent: index == 0,
                      isJoined: isJoined,
                      hasJoinedAnyTeam: hasJoinedAny,
                      minutesLeft: minsLeft,
                      onJoin: () => onJoin(req),
                      onLeave: onLeave,
                      onOpenChat: () => onOpenChat(req),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A single request row card inside [_GroundRequestsSheet].
class _RequestListCard extends StatelessWidget {
  const _RequestListCard({
    required this.request,
    required this.groundLabel,
    required this.timeAgo,
    required this.isUrgent,
    required this.isJoined,
    required this.hasJoinedAnyTeam,
    required this.minutesLeft,
    required this.onJoin,
    required this.onLeave,
    required this.onOpenChat,
  });

  final TeamRequest request;
  final String groundLabel;
  final String timeAgo;
  final bool isUrgent;
  final bool isJoined;
  final bool hasJoinedAnyTeam;
  final int minutesLeft;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spotsLeft = request.playersNeeded - request.currentPlayers;
    final isExpiringSoon = minutesLeft <= 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isJoined
            ? const Color(0xFF0D1F0D)
            : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isJoined
              ? const Color(0xFF7CFC00).withOpacity(0.45)
              : isUrgent
                  ? const Color(0xFF7CFC00).withOpacity(0.32)
                  : Colors.white.withOpacity(0.07),
          width: (isJoined || isUrgent) ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circular progress
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: request.progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(
                        request.isFull
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${request.currentPlayers}/${request.playersNeeded}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            groundLabel,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (isJoined) ...[  
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7CFC00).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle,
                                    size: 10,
                                    color: Color(0xFF7CFC00)),
                                const SizedBox(width: 3),
                                Text(
                                  'JOINED',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF7CFC00),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (isUrgent) ...[  
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7CFC00).withOpacity(0.14),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'OLDEST',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF7CFC00),
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Created $timeAgo  •  '
                      '$spotsLeft spot${spotsLeft != 1 ? 's' : ''} left',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Expiry indicator
                    Text(
                      isExpiringSoon
                          ? 'Expires in ${minutesLeft}m ⚠'
                          : '${minutesLeft}m remaining',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isExpiringSoon
                            ? Colors.orange.shade400
                            : Colors.white24,
                        fontSize: 10,
                        fontWeight: isExpiringSoon
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Join / joined action column
              if (isJoined)
                const Icon(Icons.check_circle,
                    color: Color(0xFF7CFC00), size: 28)
              else if (hasJoinedAnyTeam)
                Opacity(
                  opacity: 0.4,
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'In team',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 38,
                  child: request.isFull
                      ? OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white38,
                            side: const BorderSide(color: Colors.white12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'FULL',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        )
                      : OutlinedButton(
                          onPressed: onJoin,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7CFC00),
                            side: const BorderSide(
                                color: Color(0xFF7CFC00), width: 1.5),
                            backgroundColor:
                                const Color(0xFF7CFC00).withOpacity(0.08),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'JOIN',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1,
                              color: Color(0xFF7CFC00),
                            ),
                          ),
                        ),
                ),
            ],
          ),
          // Slot progress bar
          const SizedBox(height: 10),
          // Expiry progress bar (30 min timeline)
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (30 - minutesLeft) / 30,
                    minHeight: 3,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(
                      isExpiringSoon
                          ? Colors.orange.shade600
                          : Colors.white24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(request.playersNeeded, (i) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < request.currentPlayers
                        ? theme.colorScheme.primary
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TEAM CHAT
// ─────────────────────────────────────────────────────────────────────────────

/// In-memory chat message for a single team request session.
class _ChatMessage {
  _ChatMessage({
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });

  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;
}

/// Ephemeral team chat bottom sheet tied to a single [TeamRequest].
class _TeamChatSheet extends StatefulWidget {
  const _TeamChatSheet({
    required this.request,
    required this.currentUserId,
    required this.currentUserName,
    required this.messages,
    required this.onSend,
  });

  final TeamRequest request;
  final String currentUserId;
  final String currentUserName;
  final List<_ChatMessage> messages;
  final ValueChanged<_ChatMessage> onSend;

  @override
  State<_TeamChatSheet> createState() => _TeamChatSheetState();
}

class _TeamChatSheetState extends State<_TeamChatSheet> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    final msg = _ChatMessage(
      userId: widget.currentUserId,
      userName: widget.currentUserName,
      text: text,
      timestamp: DateTime.now(),
    );
    widget.onSend(msg);
    _inputCtrl.clear();
    // Rebuild the sheet immediately so the new message appears without
    // needing to dismiss the keyboard first.
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _fmt(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groundName =
        widget.request.groundNumber == 1 ? 'Sand Ground' : 'Hard Ground';
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
            // ── Handle + Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          color: Color(0xFF4A90D9), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TEAM CHAT',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF4A90D9)
                                    .withOpacity(0.7),
                                letterSpacing: 2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              groundName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.request.currentPlayers}/'
                          '${widget.request.playersNeeded} players',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white54, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
                color: Colors.white.withOpacity(0.06), height: 16),
            // ── Message list ────────────────────────────────────────────
            Expanded(
              child: widget.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 40,
                              color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 12),
                          Text(
                            'No messages yet.\nSay hi to your team!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white30,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      itemCount: widget.messages.length,
                      itemBuilder: (context, i) {
                        final msg = widget.messages[i];
                        final isMe =
                            msg.userId == widget.currentUserId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              if (!isMe) ...[
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      const Color(0xFF2A2A4A),
                                  child: Text(
                                    msg.userName.isNotEmpty
                                        ? msg.userName[0]
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4A90D9),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Padding(
                                        padding: const EdgeInsets
                                            .only(
                                            bottom: 3, left: 2),
                                        child: Text(
                                          msg.userName,
                                          style: theme
                                              .textTheme.labelSmall
                                              ?.copyWith(
                                            color: Colors.white38,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? const Color(0xFF1B3A1B)
                                            : const Color(0xFF1E1E1E),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isMe
                                              ? const Color(0xFF7CFC00)
                                                  .withOpacity(0.25)
                                              : Colors.white
                                                  .withOpacity(0.07),
                                        ),
                                      ),
                                      child: Text(
                                        msg.text,
                                        style: theme
                                            .textTheme.bodySmall
                                            ?.copyWith(
                                          color: Colors.white.withOpacity(0.87),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 3, left: 2, right: 2),
                                      child: Text(
                                        _fmt(msg.timestamp),
                                        style: theme
                                            .textTheme.labelSmall
                                            ?.copyWith(
                                          color: Colors.white24,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isMe) const SizedBox(width: 4),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // ── Text input ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border(
                  top: BorderSide(
                      color: Colors.white.withOpacity(0.06)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: TextField(
                        controller: _inputCtrl,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Message your team...',
                          hintStyle: TextStyle(
                              color: Colors.white30, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _send(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7CFC00),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7CFC00)
                                .withOpacity(0.35),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            // Keyboard spacer — sits under the keyboard so the input
            // stays visible without needing to dismiss the keyboard.
            SizedBox(height: viewInsets),
          ],
        ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STANDALONE MATCH TIMER SHEET
// ─────────────────────────────────────────────────────────────────────────────

/// A utility 10-minute timer not tied to any specific match.
///
/// The sheet has its own 1-second tick for UI refresh only.
/// All authoritative state lives in [_FootballScreenState].
class _SimpleTimerSheet extends StatefulWidget {
  const _SimpleTimerSheet({
    required this.getElapsedSeconds,
    required this.isRunning,
    required this.onStart,
    required this.onStop,
    required this.onReset,
  });

  final int Function() getElapsedSeconds;
  final bool Function() isRunning;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;

  @override
  State<_SimpleTimerSheet> createState() => _SimpleTimerSheetState();
}

class _SimpleTimerSheetState extends State<_SimpleTimerSheet> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _fmt(int totalSeconds) {
    final c = totalSeconds.clamp(0, 600);
    return '${(c ~/ 60).toString().padLeft(2, '0')}:${(c % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsed = widget.getElapsedSeconds();
    final running = widget.isRunning();
    final progress = (elapsed / 600).clamp(0.0, 1.0);
    final isFullTime = elapsed >= 600;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Label
          Text(
            'MATCH TIMER',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white38,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Large digital display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: Text(
              _fmt(elapsed),
              key: ValueKey(elapsed),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 6,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Status line
          Text(
            isFullTime
                ? 'FULL TIME'
                : running
                    ? 'RUNNING'
                    : elapsed == 0
                        ? 'NOT STARTED'
                        : 'STOPPED',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isFullTime
                  ? Colors.red.shade400
                  : running
                      ? theme.colorScheme.primary
                      : Colors.white38,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('00:00',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.white38)),
                  Text('10:00',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.white38)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (_, value, __) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(
                      isFullTime
                          ? Colors.red.shade700
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // START — only when not running and not full time
          if (!running && !isFullTime)
            _ActionButton(
              label: 'START',
              backgroundColor: const Color(0xFF1B5E20),
              textColor: Colors.white,
              onPressed: () {
                widget.onStart();
                setState(() {});
              },
            ),

          // STOP — GOLDEN GOAL — only when running
          if (running) ...[  
            _ActionButton(
              label: 'STOP — GOLDEN GOAL',
              backgroundColor: const Color(0xFFB71C1C),
              textColor: Colors.white,
              onPressed: () {
                widget.onStop();
                setState(() {});
              },
            ),
          ],

          const SizedBox(height: 10),

          // RESET — always visible
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white54,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                widget.onReset();
                setState(() {});
              },
              child: Text(
                'RESET',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared elevated button used inside [_SimpleTimerSheet].
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: textColor,
                ),
          ),
        ),
      ),
    );
  }
}