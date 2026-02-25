import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  /// Mock data for active games
  final List<Map<String, dynamic>> _activeGames = [
    {
      'groundNumber': 1,
      'team1': 'Team Alpha',
      'team2': 'Team Beta',
      'timeStarted': DateTime.now().subtract(const Duration(minutes: 15)),
      'waitingTeams': 2,
    },
    {
      'groundNumber': 3,
      'team1': 'Team Gamma',
      'team2': 'Team Delta',
      'timeStarted': DateTime.now().subtract(const Duration(minutes: 35)),
      'waitingTeams': 1,
    },
  ];

  /// Mock data for team requests
  late List<TeamRequest> _teamRequests;

  /// Selected ground for creating new team request
  int _selectedGround = 1;

  /// Selected player count for creating new team request
  int _selectedPlayers = 3;

  /// Loading state flag
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _teamRequests = [
      TeamRequest(
        id: '1',
        sport: 'Football',
        groundNumber: 2,
        playersNeeded: 6,
        currentPlayers: 3,
        playerIds: ['user1', 'user2', 'user3'],
        creatorId: 'creator1',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        status: 'active',
      ),
      TeamRequest(
        id: '2',
        sport: 'Football',
        groundNumber: 4,
        playersNeeded: 5,
        currentPlayers: 2,
        playerIds: ['user4', 'user5'],
        creatorId: 'creator2',
        createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
        status: 'active',
      ),
      TeamRequest(
        id: '3',
        sport: 'Football',
        groundNumber: 5,
        playersNeeded: 4,
        currentPlayers: 1,
        playerIds: ['user6'],
        creatorId: 'creator3',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: 'active',
      ),
    ];
  }

  /// Refreshes the data (mock implementation)
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  /// Shows bottom sheet to create a new team request
  void _showCreateTeamSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      builder: (context) => _buildCreateTeamModal(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  /// Builds the modal for creating a team request
  Widget _buildCreateTeamModal() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
          // Header with close button
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

          // Ground Selection
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
              value: _selectedGround,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: const Color(0xFF121212),
              items: List.generate(
                5,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('Ground ${index + 1}'),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedGround = value);
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // Players Needed Selection
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
              value: _selectedPlayers,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: const Color(0xFF121212),
              items: List.generate(
                5,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1} ${index + 1 == 1 ? 'Player' : 'Players'}'),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPlayers = value);
                }
              },
            ),
          ),
          const SizedBox(height: 32),

          // Create Button
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
                // Add new team request
                setState(() {
                  _teamRequests.insert(
                    0,
                    TeamRequest(
                      id: DateTime.now().toString(),
                      sport: 'Football',
                      groundNumber: _selectedGround,
                      playersNeeded: _selectedPlayers,
                      currentPlayers: 1,
                      playerIds: ['currentUser'],
                      creatorId: 'currentUser',
                      createdAt: DateTime.now(),
                      status: 'active',
                    ),
                  );
                });
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Team request created successfully!'),
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

  /// Formats the duration into a time string
  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('FOOTBALL'),
        actions: [
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTeamSheet,
        icon: const Icon(Icons.search),
        label: const Text('FIND PLAYERS'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Active Games Section
            if (_activeGames.isNotEmpty) ...[
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF7CFC00), Color(0xFF9AFF00)],
                ).createShader(bounds),
                child: Text(
                  'ACTIVE GAMES',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._activeGames.map((game) => _buildActiveGameCard(game, theme)),
              const SizedBox(height: 24),
            ],

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
      ),
    );
  }

  /// Builds an active game card
  Widget _buildActiveGameCard(Map<String, dynamic> game, ThemeData theme) {
    final timeStarted = game['timeStarted'] as DateTime;
    final duration = DateTime.now().difference(timeStarted);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ground ${game['groundNumber']}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Text(
                  'LIVE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Teams
            Text(
              '${game['team1']} vs ${game['team2']}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Time and Waiting Teams
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Playing',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(duration),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waiting Teams',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${game['waitingTeams']} team${game['waitingTeams'] != 1 ? 's' : ''}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a team request card
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
                    'Ground ${request.groundNumber}',
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
