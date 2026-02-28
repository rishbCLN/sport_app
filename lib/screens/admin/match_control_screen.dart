import 'package:flutter/material.dart';
import '../../models/match.dart';
import '../../services/tournament_service.dart';
import 'match_management_screen.dart';

class MatchControlScreen extends StatelessWidget {
  const MatchControlScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matches = _collectAdminMatches();

    return Scaffold(
      appBar: AppBar(title: const Text('Live Match Control')),
      body: matches.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No live or scheduled matches yet. Create a schedule from a tournament to control matches here.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final entry = matches[index];
                final m = entry.match;
                return Card(
                  color: const Color(0xFF111111),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('${entry.tournamentName} • ${m.round}'),
                    subtitle: Text(
                      '${m.team1Name} vs ${m.team2Name}\n${_fmtDateTime(m.scheduledTime)}',
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: () => MatchManagementSheet.show(context, m),
                      child: const Text('Manage'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  List<_MatchEntry> _collectAdminMatches() {
    final entries = <_MatchEntry>[];
    final tournaments = TournamentService.instance.getTournaments();

    for (final t in tournaments) {
      for (final m in t.matchSchedule) {
        if (m.status == 'live' || m.status == 'scheduled') {
          entries.add(_MatchEntry(match: m, tournamentName: t.name));
        }
      }
    }

    entries.sort(
      (a, b) => a.match.scheduledTime.compareTo(b.match.scheduledTime),
    );
    return entries;
  }

  String _fmtDateTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day}/${d.month}/${d.year}  $h:$m $ap';
  }
}

class _MatchEntry {
  final TournamentMatch match;
  final String tournamentName;

  _MatchEntry({required this.match, required this.tournamentName});
}
