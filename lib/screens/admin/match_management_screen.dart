import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/match.dart';
import '../../services/tournament_service.dart';

/// Admin bottom sheet to start, score and end a match.
class MatchManagementSheet extends StatefulWidget {
  final TournamentMatch match;

  const MatchManagementSheet({Key? key, required this.match}) : super(key: key);

  static void show(BuildContext context, TournamentMatch match) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MatchManagementSheet(match: match),
    );
  }

  @override
  State<MatchManagementSheet> createState() => _MatchManagementSheetState();
}

class _MatchManagementSheetState extends State<MatchManagementSheet> {
  late TournamentMatch _match;
  late TextEditingController _score1Ctrl;
  late TextEditingController _score2Ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _match = widget.match;
    _score1Ctrl = TextEditingController(
        text: _match.team1Score?.toString() ?? '0');
    _score2Ctrl = TextEditingController(
        text: _match.team2Score?.toString() ?? '0');
  }

  @override
  void dispose() {
    _score1Ctrl.dispose();
    _score2Ctrl.dispose();
    super.dispose();
  }

  void _save(TournamentMatch updated) {
    setState(() {
      _saving = true;
      _match = updated;
    });
    TournamentService.instance.updateMatch(updated);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _saving = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = _match;
    final isScheduled = m.status == 'scheduled';
    final isLive = m.status == 'live';
    final isCompleted = m.status == 'completed';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isLive
                ? Colors.red.withOpacity(0.4)
                : const Color(0xFF7CFC00).withOpacity(0.2),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Text(
              '${m.round.toUpperCase()} — MATCH ${m.matchNumber}',
              style: GoogleFonts.audiowide(
                color: const Color(0xFF7CFC00),
                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 16),
            // Team names
            Row(
              children: [
                Expanded(
                  child: Text(m.team1Name,
                      style: GoogleFonts.rajdhani(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('VS',
                      style: GoogleFonts.audiowide(color: Colors.white38, fontSize: 14)),
                ),
                Expanded(
                  child: Text(m.team2Name,
                      style: GoogleFonts.rajdhani(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${_fmtDateTime(m.scheduledTime)} · ${m.ground}',
              style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),

            // START MATCH button
            if (isScheduled) ...[
              _adminBtn(
                label: 'START MATCH',
                icon: Icons.play_circle_filled,
                color: const Color(0xFF4CAF50),
                onTap: () {
                  _save(_match.copyWith(
                    status: 'live',
                    actualStartTime: DateTime.now(),
                    team1Score: 0,
                    team2Score: 0,
                  ));
                },
              ),
              const SizedBox(height: 12),
            ],

            // SCORE INPUT (live or completed)
            if (isLive || isCompleted) ...[
              Text(
                'SCORE',
                style: GoogleFonts.audiowide(
                    color: Colors.white38, fontSize: 10, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _scoreField(
                        ctrl: _score1Ctrl, label: m.team1Name.split(' ').first),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('–',
                        style: GoogleFonts.audiowide(
                            color: Colors.white38, fontSize: 24)),
                  ),
                  Expanded(
                    child: _scoreField(
                        ctrl: _score2Ctrl, label: m.team2Name.split(' ').first),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    final s1 = int.tryParse(_score1Ctrl.text) ?? 0;
                    final s2 = int.tryParse(_score2Ctrl.text) ?? 0;
                    _save(_match.copyWith(team1Score: s1, team2Score: s2));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Score updated'),
                          backgroundColor: Color(0xFF4CAF50)),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7CFC00)),
                    foregroundColor: const Color(0xFF7CFC00),
                    textStyle: GoogleFonts.rajdhani(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('UPDATE SCORE'),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // END MATCH button
            if (isLive) ...[
              _adminBtn(
                label: 'END MATCH & RECORD RESULT',
                icon: Icons.stop_circle,
                color: const Color(0xFFF44336),
                onTap: () => _showEndMatchDialog(context),
              ),
              const SizedBox(height: 12),
            ],

            // RESCHEDULE button
            if (!isCompleted) ...[
              _adminBtn(
                label: 'RESCHEDULE',
                icon: Icons.calendar_month,
                color: const Color(0xFFFF9800),
                onTap: () => _showRescheduleDialog(context),
              ),
              const SizedBox(height: 12),
            ],

            // MARK POSTPONED
            if (isScheduled) ...[
              _adminBtn(
                label: 'MARK AS POSTPONED',
                icon: Icons.pause_circle_outline,
                color: Colors.orange,
                outlined: true,
                onTap: () {
                  _save(_match.copyWith(status: 'postponed'));
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _adminBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                foregroundColor: color,
                textStyle: GoogleFonts.rajdhani(
                    fontSize: 14, fontWeight: FontWeight.w800),
              ),
              onPressed: onTap,
            )
          : ElevatedButton.icon(
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.rajdhani(
                    fontSize: 14, fontWeight: FontWeight.w800),
              ),
              onPressed: onTap,
            ),
    );
  }

  Widget _scoreField({required TextEditingController ctrl, required String label}) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.rajdhani(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.audiowide(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  void _showEndMatchDialog(BuildContext context) {
    final s1 = int.tryParse(_score1Ctrl.text) ?? 0;
    final s2 = int.tryParse(_score2Ctrl.text) ?? 0;
    final winnerName = s1 > s2
        ? _match.team1Name
        : s2 > s1
            ? _match.team2Name
            : 'Draw';
    final winnerId = s1 > s2
        ? _match.team1Id
        : s2 > s1
            ? _match.team2Id
            : null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('End Match',
            style: GoogleFonts.audiowide(color: const Color(0xFF7CFC00), fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Final Score: $s1 – $s2',
                style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              winnerId != null ? 'Winner: $winnerName' : 'Result: Draw',
              style: GoogleFonts.rajdhani(
                  color: const Color(0xFF7CFC00),
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.rajdhani(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF44336)),
            onPressed: () {
              _save(_match.copyWith(
                status: 'completed',
                team1Score: s1,
                team2Score: s2,
                winnerId: winnerId,
                actualEndTime: DateTime.now(),
              ));
              Navigator.pop(context); // dialog
              Navigator.pop(context); // sheet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    winnerId != null
                        ? '$winnerName wins!'
                        : 'Match ended in a draw',
                    style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              );
            },
            child: Text('CONFIRM',
                style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _match.scheduledTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF7CFC00)),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_match.scheduledTime),
    );
    if (time == null || !mounted) return;
    final newTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
    _save(_match.copyWith(scheduledTime: newTime));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match rescheduled'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  String _fmtDateTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day}/${d.month}/${d.year} $h:$min $ap';
  }
}
