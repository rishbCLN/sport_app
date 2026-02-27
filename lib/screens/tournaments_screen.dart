import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';
import '../widgets/tournament_card.dart';
import 'tournament_detail_screen.dart';
import 'admin/admin_tournament_screen.dart';

/// Tournaments screen — user view with hidden admin access.
class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({Key? key}) : super(key: key);

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  List<Tournament> _tournaments = [];
  String _sportFilter = 'All';
  String _statusFilter = 'All';

  // Hidden admin access — tap title 7 times rapidly
  int _titleTapCount = 0;
  Timer? _tapResetTimer;

  @override
  void initState() {
    super.initState();
    // Seed data on first load
    TournamentService.instance.seedDemoData();
    _load();
    TournamentService.instance.addListener(_load);
  }

  void _load() {
    if (mounted) {
      setState(() {
        _tournaments = TournamentService.instance.getTournaments();
      });
    }
  }

  @override
  void dispose() {
    TournamentService.instance.removeListener(_load);
    _tapResetTimer?.cancel();
    super.dispose();
  }

  void _onTitleTap() {
    _tapResetTimer?.cancel();
    _titleTapCount++;
    _tapResetTimer = Timer(const Duration(seconds: 2), () {
      _titleTapCount = 0;
    });
    if (_titleTapCount >= 7) {
      _titleTapCount = 0;
      _tapResetTimer?.cancel();
      _showAdminPasswordDialog();
    }
  }

  void _showAdminPasswordDialog() {
    final ctrl = TextEditingController();
    bool hasError = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text('Admin Access',
              style: GoogleFonts.audiowide(
                  color: const Color(0xFF7CFC00), fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter admin password to continue',
                  style: GoogleFonts.rajdhani(
                      color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                obscureText: true,
                autofocus: true,
                style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: hasError ? 'Incorrect password' : null,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                onSubmitted: (_) => _checkPassword(ctrl.text, ctx,
                    () => setDialogState(() => hasError = true)),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel',
                    style: GoogleFonts.rajdhani(color: Colors.white60))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7CFC00),
                  foregroundColor: Colors.black),
              onPressed: () => _checkPassword(ctrl.text, ctx,
                  () => setDialogState(() => hasError = true)),
              child: Text('LOGIN AS ADMIN',
                  style: GoogleFonts.rajdhani(
                      fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _checkPassword(
      String password, BuildContext dialogCtx, VoidCallback onError) {
    if (password == 'admin123') {
      Navigator.pop(dialogCtx);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminTournamentScreen()),
      );
    } else {
      onError();
    }
  }

  List<Tournament> get _filtered {
    return _tournaments.where((t) {
      final sportOk = _sportFilter == 'All' || t.sport == _sportFilter;
      final statusOk = _statusFilter == 'All' ||
          (_statusFilter == 'Upcoming' &&
              (t.status == 'upcoming' || t.status == 'registration_open')) ||
          (_statusFilter == 'Ongoing' && t.status == 'ongoing') ||
          (_statusFilter == 'Completed' && t.status == 'completed');
      return sportOk && statusOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: GestureDetector(
          onTap: _onTitleTap,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'TOURNAMENTS',
            style: GoogleFonts.audiowide(
              color: const Color(0xFF7CFC00),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Sport filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                ..._sportChips(),
                Container(
                    width: 1, height: 24, color: Colors.white10,
                    margin: const EdgeInsets.symmetric(horizontal: 8)),
                ..._statusChips(),
              ],
            ),
          ),
          // Main list
          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : RefreshIndicator(
                    color: const Color(0xFF7CFC00),
                    backgroundColor: const Color(0xFF121212),
                    onRefresh: () async {
                      _load();
                      await Future.delayed(const Duration(milliseconds: 400));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final t = filtered[i];
                        return TournamentCard(
                          tournament: t,
                          onTap: () => _openDetail(t.id),
                          onRegister: t.canRegister()
                              ? () => _openDetail(t.id)
                              : null,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _openDetail(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TournamentDetailScreen(tournamentId: id),
      ),
    );
  }

  List<Widget> _sportChips() {
    return ['All', 'Football', 'Badminton', 'Cricket'].map((s) {
      final sel = _sportFilter == s;
      Color c;
      if (s == 'Football') c = const Color(0xFF2196F3);
      else if (s == 'Badminton') c = const Color(0xFF4CAF50);
      else if (s == 'Cricket') c = const Color(0xFFFF9800);
      else c = const Color(0xFF7CFC00);

      return GestureDetector(
        onTap: () => setState(() => _sportFilter = s),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: sel ? c.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? c : Colors.white24),
          ),
          child: Text(
            s,
            style: GoogleFonts.rajdhani(
              color: sel ? c : Colors.white60,
              fontSize: 13, fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _statusChips() {
    return ['All', 'Upcoming', 'Ongoing', 'Completed'].map((s) {
      final sel = _statusFilter == s;
      Color c;
      if (s == 'Ongoing') c = Colors.red;
      else if (s == 'Upcoming') c = const Color(0xFF2196F3);
      else if (s == 'Completed') c = Colors.white38;
      else c = const Color(0xFF7CFC00);

      return GestureDetector(
        onTap: () => setState(() => _statusFilter = s),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: sel ? c.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? c : Colors.white24),
          ),
          child: Text(
            s,
            style: GoogleFonts.rajdhani(
              color: sel ? c : Colors.white60,
              fontSize: 12, fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events,
              size: 64, color: const Color(0xFF7CFC00).withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No tournaments found',
            style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.rajdhani(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
