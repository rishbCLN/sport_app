import 'dart:async';
import 'package:flutter/material.dart';
import '../models/team_request.dart';

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

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    super.dispose();
  }

  /// Returns the display name for a ground number.
  String _getGroundName(int groundNumber) {
    return groundNumber == 1 ? 'Sand Ground' : 'Hard Ground';
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
                            content:
                                const Text('Team request created successfully!'),
                            backgroundColor: const Color(0xFF7CFC00),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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

  /// Opens the "Join a Team" ground map modal.
  ///
  /// Uses a macOS-style scale-from-bottom + fade page transition so the modal
  /// feels like it rises and expands from the FAB position.
  void _showJoinTeamModal() {
    Navigator.push<void>(
      context,
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.78),
        transitionDuration: const Duration(milliseconds: 340),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, _, __) => _JoinTeamModal(
          teamRequests: _teamRequests,
          onJoin: (_) => setState(() {}),
        ),
        transitionsBuilder: (ctx, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// Formats the time difference into a human-readable string
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
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
              content: const Text('Full time — 10 minutes completed'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
          content: const Text('Match ended — Golden goal'),
          backgroundColor: const Color(0xFF7CFC00),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: Colors.transparent,
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'join_team_fab',
            onPressed: _showJoinTeamModal,
            icon: const Icon(Icons.groups_outlined),
            label: const Text('JOIN A TEAM'),
            backgroundColor: const Color(0xFF1A2A3A),
            foregroundColor: const Color(0xFF4A90D9),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'find_players_fab',
            onPressed: _showCreateTeamSheet,
            icon: const Icon(Icons.search),
            label: const Text('FIND PLAYERS'),
          ),
        ],
      ),
      body: _buildListView(theme),
    );
  }

  /// Builds the list view (original view)
  Widget _buildListView(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Looking for Players Section
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF7CFC00), Color(0xFF9AFF00)],
              ).createShader(bounds),
              child: Text(
                'LOOKING FOR PLAYERS',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_teamRequests.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7CFC00).withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.groups_2_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'NO TEAM REQUESTS YET',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary.withOpacity(0.7),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._teamRequests.map((request) =>
                  _buildTeamRequestCard(request, theme)),
            const SizedBox(height: 24),
          ],
        ),
      );
  }


  /// Builds a team request card  /// Builds a team request card
  Widget _buildTeamRequestCard(TeamRequest request, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with ground and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getGroundName(request.groundNumber),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                Text(
                  _getTimeAgo(request.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Players status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Players Needed',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request.currentPlayers}/${request.playersNeeded}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular Progress Indicator
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: request.progress,
                          strokeWidth: 6,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            request.isFull
                                ? Colors.green
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      // Center text
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(request.progress * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Player avatars and join button
            Row(
              children: [
                // Avatars
                SizedBox(
                  width: 100,
                  child: Stack(
                    children: List.generate(
                      request.currentPlayers,
                      (index) => Positioned(
                        left: index * 20.0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            'P${index + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Join button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: request.isFull
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Joined team request!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                  child: Text(
                    request.isFull ? 'Full' : 'Join',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JOIN A TEAM — MODAL & RELATED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Ground definitions used by the Join a Team modal.
/// Odd ground numbers are sand pitches; even are hard-court pitches.
const List<Map<String, Object>> _kGrounds = [
  {'id': 'sand', 'label': 'Sand Ground', 'numbers': <int>[1]},
  {'id': 'hard', 'label': 'Hard Ground', 'numbers': <int>[2]},
];

/// Full-screen "Join a Team" ground-map modal.
///
/// Displays [_kGrounds] as large tappable cards with an animated deck-of-cards
/// overlay when requests exist. Tapping opens [_GroundRequestsSheet].
class _JoinTeamModal extends StatefulWidget {
  const _JoinTeamModal({
    required this.teamRequests,
    required this.onJoin,
  });

  final List<TeamRequest> teamRequests;
  final ValueChanged<TeamRequest> onJoin;

  @override
  State<_JoinTeamModal> createState() => _JoinTeamModalState();
}

class _JoinTeamModalState extends State<_JoinTeamModal> {
  List<TeamRequest> _requestsForGround(List<int> numbers) {
    return widget.teamRequests
        .where((r) => numbers.contains(r.groundNumber))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void _openSheet(
    BuildContext ctx,
    String groundLabel,
    List<TeamRequest> requests,
  ) {
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GroundRequestsSheet(
        groundLabel: groundLabel,
        requests: requests,
        onJoin: (req) {
          widget.onJoin(req);
          Navigator.pop(ctx);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('Joined a team at $groundLabel!'),
              backgroundColor: const Color(0xFF7CFC00),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        // Swipe-down anywhere to dismiss
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy > 400) {
            Navigator.pop(context);
          }
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SELECT A GROUND',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF4A90D9).withOpacity(0.7),
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'JOIN A TEAM',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Tap a ground to see active team requests',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white38,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Ground cards grid ───────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.70,
                    ),
                    itemCount: _kGrounds.length,
                    itemBuilder: (context, index) {
                      final ground = _kGrounds[index];
                      final numbers =
                          (ground['numbers'] as List<int>);
                      final label = ground['label'] as String;
                      final isSand = ground['id'] == 'sand';
                      final requests = _requestsForGround(numbers);
                      return _GroundCard(
                        label: label,
                        isSand: isSand,
                        requests: requests,
                        screenWidth: size.width,
                        onTap: requests.isEmpty
                            ? null
                            : () => _openSheet(context, label, requests),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A large ground card for the Join a Team modal.
///
/// Renders a custom-painted football field with:
/// - Surface-type chip (SAND / HARD)
/// - Ground name label
/// - Animated deck-of-cards overlay when requests exist
/// - Dimmed "No teams looking" empty state
class _GroundCard extends StatelessWidget {
  const _GroundCard({
    required this.label,
    required this.isSand,
    required this.requests,
    required this.screenWidth,
    required this.onTap,
  });

  final String label;
  final bool isSand;
  final List<TeamRequest> requests;
  final double screenWidth;
  final VoidCallback? onTap;

  Color get _surfaceColor =>
      isSand ? const Color(0xFF1A1306) : const Color(0xFF060D1A);

  Color get _fieldColor => isSand
      ? const Color(0xFFC8A96E).withOpacity(0.22)
      : const Color(0xFF4A90D9).withOpacity(0.16);

  Color get _accentColor =>
      isSand ? const Color(0xFFD4A847) : const Color(0xFF4A90D9);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRequests = requests.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasRequests
                ? _accentColor.withOpacity(0.55)
                : Colors.white.withOpacity(0.07),
            width: hasRequests ? 1.5 : 1,
          ),
          boxShadow: hasRequests
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Surface chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _accentColor.withOpacity(0.38),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isSand ? 'SAND' : 'HARD',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _accentColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Ground name
                    Text(
                      label,
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

  /// Builds a physical deck-of-cards stack with a count badge.
  Widget _buildDeck(ThemeData theme) {
    final count = requests.length;
    final deckDepth = count.clamp(0, 2);

    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Shadow cards behind the top card
          for (int i = 0; i < deckDepth; i++)
            Positioned(
              bottom: i * 7.0,
              left: (deckDepth - i - 1) * 4.0,
              right: -(deckDepth - i - 1) * 4.0,
              child: Transform.rotate(
                angle: (i - deckDepth / 2) * 0.055,
                child: Container(
                  height: 66,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C)
                        .withOpacity(0.88 - i * 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accentColor.withOpacity(0.18),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          // Top card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
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
          // Count badge
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

  /// Shown when the ground has no active requests.
  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.sports_soccer_outlined, size: 30, color: Colors.white24),
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
    required this.onJoin,
  });

  final String groundLabel;
  final List<TeamRequest> requests;
  final ValueChanged<TeamRequest> onJoin;

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
                    return _RequestListCard(
                      request: req,
                      groundLabel: groundLabel,
                      timeAgo: _timeAgo(req.createdAt),
                      isUrgent: index == 0,
                      onJoin: () => onJoin(req),
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
    required this.onJoin,
  });

  final TeamRequest request;
  final String groundLabel;
  final String timeAgo;
  final bool isUrgent;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spotsLeft = request.playersNeeded - request.currentPlayers;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? const Color(0xFF7CFC00).withOpacity(0.32)
              : Colors.white.withOpacity(0.07),
          width: isUrgent ? 1.5 : 1,
        ),
      ),
      child: Column(
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
                        if (isUrgent) ...[
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
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Join button
              SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: request.isFull ? null : onJoin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    request.isFull ? 'Full' : 'Join',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Slot progress bar
          const SizedBox(height: 12),
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