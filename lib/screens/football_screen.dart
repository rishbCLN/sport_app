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

class _FootballScreenState extends State<FootballScreen>
    with SingleTickerProviderStateMixin {
  /// View mode: true = map view, false = list view
  bool _isMapView = false;

  /// Animation controller for blinking markers
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

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
    
    // Initialize blink animation for map markers
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
    
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

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
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

          // Ground selection dropdown
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
          // Toggle view button
          IconButton(
            icon: Icon(_isMapView ? Icons.view_list : Icons.map_outlined),
            onPressed: () {
              setState(() => _isMapView = !_isMapView);
            },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTeamSheet,
        icon: const Icon(Icons.search),
        label: const Text('FIND PLAYERS'),
      ),
      body: _isMapView ? _buildMapView(theme) : _buildListView(theme),
    );
  }

  /// Builds the list view (original view)
  Widget _buildListView(ThemeData theme) {
    return RefreshIndicator(
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
      );
  }

  /// Builds the map view with ground locations
  Widget _buildMapView(ThemeData theme) {
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: SizedBox(
        height: 800,
        child: Stack(
          children: [
            // Map background with grey outlines
            CustomPaint(
              size: Size(width, 800),
              painter: FootballMapPainter(),
            ),

            // Ground markers
            ..._buildGroundMarkers(theme),
          ],
        ),
      ),
    );
  }

  /// Builds markers for each ground with team requests
  List<Widget> _buildGroundMarkers(ThemeData theme) {
    // Define ground positions on the map (x, y coordinates)
    final Map<int, Offset> groundPositions = {
      1: const Offset(100, 150),
      2: const Offset(250, 200),
      3: const Offset(150, 350),
      4: const Offset(280, 450),
      5: const Offset(120, 550),
    };

    List<Widget> markers = [];

    // Add markers for team requests
    for (var request in _teamRequests) {
      final position = groundPositions[request.groundNumber];
      if (position != null) {
        markers.add(
          Positioned(
            left: position.dx,
            top: position.dy,
            child: _buildGroundMarker(request, theme),
          ),
        );
      }
    }

    return markers;
  }

  /// Builds a single ground marker with blinking animation
  Widget _buildGroundMarker(TeamRequest request, ThemeData theme) {
    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Blinking circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(
                  color: const Color(0xFF7CFC00).withOpacity(_blinkAnimation.value),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7CFC00).withOpacity(_blinkAnimation.value * 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${request.currentPlayers}/${request.playersNeeded}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF7CFC00),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Ground name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                border: Border.all(
                  color: const Color(0xFF7CFC00).withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Ground ${request.groundNumber}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF7CFC00),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      },
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

/// Custom painter for football field map background
class FootballMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF444444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final gridPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw dark background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Draw subtle grid pattern
    const gridSpacing = 50.0;
    for (double i = 0; i < size.width; i += gridSpacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        gridPaint,
      );
    }
    for (double i = 0; i < size.height; i += gridSpacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        gridPaint,
      );
    }

    // Draw football field outlines (5 fields)
    final fieldPaint = Paint()
      ..color = const Color(0xFF7CFC00).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Field 1
    _drawFootballField(canvas, const Offset(60, 110), 100, 80, fieldPaint);
    
    // Field 2
    _drawFootballField(canvas, const Offset(210, 160), 100, 80, fieldPaint);
    
    // Field 3
    _drawFootballField(canvas, const Offset(110, 310), 100, 80, fieldPaint);
    
    // Field 4
    _drawFootballField(canvas, const Offset(240, 410), 100, 80, fieldPaint);
    
    // Field 5
    _drawFootballField(canvas, const Offset(80, 510), 100, 80, fieldPaint);

    // Draw outer border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      borderPaint,
    );
  }

  /// Helper method to draw a simplified football field
  void _drawFootballField(Canvas canvas, Offset position, double width, double height, Paint paint) {
    // Outer rectangle
    canvas.drawRect(
      Rect.fromLTWH(position.dx, position.dy, width, height),
      paint,
    );

    // Center line
    canvas.drawLine(
      Offset(position.dx + width / 2, position.dy),
      Offset(position.dx + width / 2, position.dy + height),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(position.dx + width / 2, position.dy + height / 2),
      15,
      paint,
    );

    // Goal areas
    canvas.drawRect(
      Rect.fromLTWH(position.dx, position.dy + height / 3, width * 0.15, height / 3),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(position.dx + width * 0.85, position.dy + height / 3, width * 0.15, height / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
