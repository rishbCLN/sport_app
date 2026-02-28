import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../services/auth_service.dart';
import '../../services/tournament_service.dart';
import '../auth/login_screen.dart';
import 'admin_tournament_screen.dart';
import 'tournament_creation_wizard.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              AuthService().logout();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tournaments = TournamentService.instance.getTournaments();
    final activeCount = tournaments.where((t) => t.status != 'completed').length;
    final teamCount = tournaments.fold<int>(0, (sum, t) => sum + t.registeredTeamIds.length);
    final liveMatches = tournaments
        .expand((t) => t.matchSchedule)
        .where((m) => m.status == 'live')
        .length;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('ADMIN PANEL'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, size: 18),
                const SizedBox(width: 6),
                Text(
                  AuthService().currentUsername ?? 'Admin',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildDashboard(
        theme,
        activeTournaments: activeCount,
        teamCount: teamCount,
        liveMatches: liveMatches,
        tournaments: tournaments,
      ),
    );
  }

  Widget _buildDashboard(
    ThemeData theme, {
    required int activeTournaments,
    required int teamCount,
    required int liveMatches,
    required List<Tournament> tournaments,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _welcomeCard(
            theme,
            activeTournaments: activeTournaments,
            teamCount: teamCount,
            liveMatches: liveMatches,
          ),
          const SizedBox(height: 16),
          _actionGrid(theme, activeBadge: activeTournaments),
          const SizedBox(height: 16),
          _recentActivity(theme, tournaments),
        ],
      ),
    );
  }

  Widget _welcomeCard(
    ThemeData theme, {
    required int activeTournaments,
    required int teamCount,
    required int liveMatches,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.waving_hand, color: Colors.amber, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, Admin', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _statChip('Active Tournaments', '$activeTournaments'),
                    _statChip('Teams', '$teamCount'),
                    _statChip('Live Matches', '$liveMatches'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Colors.white10,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  Widget _actionGrid(ThemeData theme, {required int activeBadge}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _actionCard(
          title: 'Host New Tournament',
          icon: Icons.add_circle_outline,
          colors: const [Color(0xFF2196F3), Color(0xFF64B5F6)],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TournamentCreationWizard()),
            );
          },
        ),
        _actionCard(
          title: 'Manage Active Tournaments',
          icon: Icons.list_alt,
          colors: const [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          badge: activeBadge > 0 ? '$activeBadge' : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminTournamentScreen()),
            );
          },
        ),
        _actionCard(
          title: 'Team Registrations',
          icon: Icons.groups,
          colors: const [Color(0xFFFF9800), Color(0xFFFFB74D)],
          onTap: () {},
        ),
        _actionCard(
          title: 'Live Match Control',
          icon: Icons.timer,
          colors: const [Color(0xFFE53935), Color(0xFFEF5350)],
          onTap: () {},
        ),
      ],
    );
  }

  Widget _actionCard({
    required String title,
    required IconData icon,
    required List<Color> colors,
    VoidCallback? onTap,
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 32, color: Colors.white),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(badge, style: const TextStyle(color: Colors.white)),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentActivity(ThemeData theme, List<Tournament> tournaments) {
    final sorted = [...tournaments]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final activities = sorted.take(6).map<String>((t) {
      final status = t.status.replaceAll('_', ' ').toUpperCase();
      return '${t.name} • ${t.sport} • $status';
    }).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            Text(
              'No activity yet. Create or manage a tournament to get started.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
            )
          else
            ...activities.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
