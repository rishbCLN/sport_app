import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/tournament.dart';
import '../../services/tournament_service.dart';
import 'tournament_creation_wizard.dart';
import 'tournament_management_screen.dart';

Color _sportColor(String sport) {
  switch (sport) {
    case 'Football':
      return const Color(0xFF2196F3);
    case 'Badminton':
      return const Color(0xFF4CAF50);
    case 'Cricket':
      return const Color(0xFFFF9800);
    default:
      return const Color(0xFF7CFC00);
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

/// Admin-only tournament management screen.
class AdminTournamentScreen extends StatefulWidget {
  const AdminTournamentScreen({Key? key}) : super(key: key);

  @override
  State<AdminTournamentScreen> createState() => _AdminTournamentScreenState();
}

class _AdminTournamentScreenState extends State<AdminTournamentScreen> {
  List<Tournament> _tournaments = [];

  @override
  void initState() {
    super.initState();
    _load();
    TournamentService.instance.addListener(_load);
  }

  void _load() {
    if (!mounted) return;
    setState(() {
      _tournaments = TournamentService.instance.getTournaments();
    });
  }

  @override
  void dispose() {
    TournamentService.instance.removeListener(_load);
    super.dispose();
  }

  List<Tournament> get _active =>
      _tournaments.where((t) => t.status != 'completed').toList();
  List<Tournament> get _completed =>
      _tournaments.where((t) => t.status == 'completed').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7CFC00),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TournamentCreationWizard()),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7CFC00)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOURNAMENT ADMIN',
              style: GoogleFonts.audiowide(
                color: const Color(0xFF7CFC00),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Admin Mode Active',
              style: GoogleFonts.rajdhani(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Exit Admin Mode',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF7CFC00),
        backgroundColor: const Color(0xFF121212),
        onRefresh: () async {
          _load();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('ACTIVE TOURNAMENTS (${_active.length})'),
              if (_active.isEmpty)
                _emptyState('No active tournaments')
              else
                ..._active.map((t) => _tournamentAdminCard(context, t)),
              const SizedBox(height: 16),
              _collapsibleCompleted(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _collapsibleCompleted() {
    if (_completed.isEmpty) return const SizedBox.shrink();
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        iconColor: Colors.white38,
        collapsedIconColor: Colors.white24,
        title: Text(
          'COMPLETED TOURNAMENTS (${_completed.length})',
          style: GoogleFonts.audiowide(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        children: _completed
            .map((t) => _tournamentAdminCard(context, t))
            .toList(),
      ),
    );
  }

  Widget _tournamentAdminCard(BuildContext context, Tournament tournament) {
    final color = _sportColor(tournament.sport);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(_sportIcon(tournament.sport), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.name,
                      style: GoogleFonts.rajdhani(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      tournament.sport,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(tournament.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${tournament.startDate.day}/${tournament.startDate.month} - '
            '${tournament.endDate.day}/${tournament.endDate.month}',
            style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _infoChip(Icons.groups, '${tournament.currentTeams}/${tournament.maxTeams} teams'),
              const SizedBox(width: 8),
              _infoChip(Icons.place, tournament.venue),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TournamentManagementScreen(
                      tournamentId: tournament.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility, color: Color(0xFF7CFC00)),
              label: const Text(
                'Manage',
                style: TextStyle(color: Color(0xFF7CFC00)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'registration_open':
        color = Colors.orange;
        break;
      case 'ongoing':
        color = Colors.greenAccent;
        break;
      case 'completed':
        color = Colors.blueGrey;
        break;
      default:
        color = Colors.white54;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.audiowide(
          color: color,
          fontSize: 10,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF7CFC00)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.audiowide(
          color: const Color(0xFF7CFC00),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _emptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy, color: Colors.white38),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the Create button to add a tournament.',
            style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
