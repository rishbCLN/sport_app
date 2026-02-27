import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/tournament.dart';
import '../../services/tournament_service.dart';
import 'tournament_management_screen.dart';

Color _sportColor(String sport) {
  switch (sport) {
    case 'Football': return const Color(0xFF2196F3);
    case 'Badminton': return const Color(0xFF4CAF50);
    case 'Cricket': return const Color(0xFFFF9800);
    default: return const Color(0xFF7CFC00);
  }
}

IconData _sportIcon(String sport) {
  switch (sport) {
    case 'Football': return Icons.sports_soccer;
    case 'Badminton': return Icons.sports_tennis;
    case 'Cricket': return Icons.sports_cricket;
    default: return Icons.emoji_events;
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
    if (mounted) {
      setState(() {
        _tournaments = TournamentService.instance.getTournaments();
      });
    }
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7CFC00)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TOURNAMENT ADMIN',
                style: GoogleFonts.audiowide(
                    color: const Color(0xFF7CFC00),
                    fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            Text('Admin Mode Active',
                style: GoogleFonts.rajdhani(
                    color: Colors.red, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          // Sample data button
          Tooltip(
            message: 'Load demo data',
            child: IconButton(
              icon: const Icon(Icons.data_object, color: Color(0xFF7CFC00)),
              onPressed: () {
                TournamentService.instance.seedDemoData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Demo data loaded!',
                        style: GoogleFonts.rajdhani(fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                );
              },
            ),
          ),
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
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CREATE TOURNAMENT button
              _createTournamentCard(),
              const SizedBox(height: 24),
              // Active tournaments
              _sectionHeader('ACTIVE TOURNAMENTS (${_active.length})'),
              if (_active.isEmpty)
                _emptyState('No active tournaments')
              else
                ..._active.map((t) => _tournamentAdminCard(context, t)),
              // Completed
              const SizedBox(height: 16),
              _collapsibleCompleted(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createTournamentCard() {
    return GestureDetector(
      onTap: () => _showCreateFlow(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A2A1A), Color(0xFF0A0A0A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF7CFC00).withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7CFC00).withOpacity(0.08),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF7CFC00).withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF7CFC00),
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CREATE NEW TOURNAMENT',
                      style: GoogleFonts.audiowide(
                          color: const Color(0xFF7CFC00),
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Set up bracket, teams, schedule',
                      style: GoogleFonts.rajdhani(
                          color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Color(0xFF7CFC00), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _tournamentAdminCard(BuildContext context, Tournament t) {
    final color = _sportColor(t.sport);
    final statusColors = {
      'upcoming': const Color(0xFF2196F3),
      'registration_open': const Color(0xFF4CAF50),
      'ongoing': const Color(0xFFF44336),
      'completed': const Color(0xFF9E9E9E),
    };
    final statusLabels = {
      'upcoming': 'UPCOMING',
      'registration_open': 'REG OPEN',
      'ongoing': 'LIVE',
      'completed': 'DONE',
    };
    final sc = statusColors[t.status] ?? Colors.white38;
    final sl = statusLabels[t.status] ?? t.status.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_sportIcon(t.sport), color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name,
                          style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 14, fontWeight: FontWeight.w800),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${t.format} · ${t.venue}',
                          style: GoogleFonts.rajdhani(
                              color: Colors.white60, fontSize: 11)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.group, size: 12, color: color),
                          const SizedBox(width: 4),
                          Text('${t.currentTeams}/${t.maxTeams} teams',
                              style: GoogleFonts.rajdhani(
                                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: sc.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: sc.withOpacity(0.4)),
                            ),
                            child: Text(sl,
                                style: GoogleFonts.rajdhani(
                                    color: sc, fontSize: 10, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider + MANAGE button
          Container(
            height: 1, color: Colors.white.withOpacity(0.05),
            margin: const EdgeInsets.symmetric(horizontal: 14),
          ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TournamentManagementScreen(tournamentId: t.id),
              ),
            ),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings, color: color, size: 16),
                  const SizedBox(width: 8),
                  Text('MANAGE',
                      style: GoogleFonts.rajdhani(
                          color: color,
                          fontSize: 13, fontWeight: FontWeight.w800,
                          letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _collapsibleCompleted() {
    if (_completed.isEmpty) return const SizedBox.shrink();
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          'COMPLETED TOURNAMENTS (${_completed.length})',
          style: GoogleFonts.audiowide(
              color: Colors.white38,
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        iconColor: Colors.white38,
        collapsedIconColor: Colors.white24,
        children: _completed.map((t) => _tournamentAdminCard(context, t)).toList(),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: GoogleFonts.audiowide(
              color: const Color(0xFF7CFC00),
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.8)),
    );
  }

  Widget _emptyState(String msg) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Text(msg,
          style: GoogleFonts.rajdhani(color: Colors.white24, fontSize: 14)),
    );
  }

  void _showCreateFlow(BuildContext context) {
    _TournamentCreateFlow.show(context);
  }
}

// ─── Create Tournament Flow ────────────────────────────────────────────────────

class _TournamentCreateFlow extends StatefulWidget {
  const _TournamentCreateFlow();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _TournamentCreateFlow(),
    );
  }

  @override
  State<_TournamentCreateFlow> createState() => _TournamentCreateFlowState();
}

class _TournamentCreateFlowState extends State<_TournamentCreateFlow> {
  int _step = 0;

  // Step 1
  final _nameCtrl = TextEditingController();
  String _sport = 'Football';
  String _venue = 'Sand Ground';
  final _prizeCtrl = TextEditingController();

  // Step 2
  String _format = 'Single Elimination';
  int _maxTeams = 8;
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  DateTime _regDeadline = DateTime.now().add(const Duration(days: 5));

  // Step 3
  final _rulesCtrl = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _prizeCtrl.dispose();
    _rulesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              // Step indicator
              Row(
                children: List.generate(3, (i) {
                  final active = i == _step;
                  final done = i < _step;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: done ? const Color(0xFF7CFC00)
                            : active ? const Color(0xFF7CFC00).withOpacity(0.6)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              if (_step == 0) _step1(),
              if (_step == 1) _step2(context),
              if (_step == 2) _step3(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepTitle('STEP 1: BASIC INFO'),
        const SizedBox(height: 14),
        TextField(
          controller: _nameCtrl,
          style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Tournament Name',
            hintText: 'e.g. VIT Inter-Hostel Cup 2024',
          ),
        ),
        const SizedBox(height: 16),
        _label('SPORT'),
        const SizedBox(height: 8),
        Row(
          children: ['Football', 'Badminton', 'Cricket'].map((s) {
            final selected = _sport == s;
            final color = selected
                ? (s == 'Football' ? const Color(0xFF2196F3)
                    : s == 'Badminton' ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800))
                : Colors.white24;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _sport = s),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color),
                  ),
                  child: Column(
                    children: [
                      Icon(_sportIconFromString(s), color: color, size: 22),
                      const SizedBox(height: 4),
                      Text(s, style: GoogleFonts.rajdhani(
                          color: color, fontSize: 11, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _label('VENUE'),
        const SizedBox(height: 8),
        Row(
          children: ['Sand Ground', 'Hard Ground', 'Indoor Court', 'Cricket Ground']
              .map((v) {
            final sel = _venue == v;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _venue = v),
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF7CFC00).withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sel ? const Color(0xFF7CFC00) : Colors.white24,
                    ),
                  ),
                  child: Text(
                    v.split(' ').first,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      color: sel ? const Color(0xFF7CFC00) : Colors.white60,
                      fontSize: 11, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _prizeCtrl,
          style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Prize Pool (optional)',
            hintText: 'e.g. ₹5,000 prize pool',
            prefixIcon: Icon(Icons.emoji_events),
          ),
        ),
        const SizedBox(height: 20),
        _nextBtn(() {
          if (_nameCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a tournament name')));
            return;
          }
          setState(() => _step = 1);
        }),
      ],
    );
  }

  Widget _step2(BuildContext context) {
    final formats = [
      'Single Elimination', 'Double Elimination', 'Round Robin', 'Group Stage + Knockout',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepTitle('STEP 2: FORMAT & SCHEDULE'),
        const SizedBox(height: 14),
        _label('FORMAT'),
        const SizedBox(height: 8),
        ...formats.map((f) {
          final sel = _format == f;
          return GestureDetector(
            onTap: () => setState(() => _format = f),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF7CFC00).withOpacity(0.1) : const Color(0xFF121212),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? const Color(0xFF7CFC00) : Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    sel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: sel ? const Color(0xFF7CFC00) : Colors.white38,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(f, style: GoogleFonts.rajdhani(
                      color: sel ? const Color(0xFF7CFC00) : Colors.white,
                      fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        _label('MAX TEAMS'),
        const SizedBox(height: 8),
        Row(
          children: [4, 8, 16, 32].map((n) {
            final sel = _maxTeams == n;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _maxTeams = n),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF7CFC00).withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? const Color(0xFF7CFC00) : Colors.white24,
                    ),
                  ),
                  child: Text(
                    '$n',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.audiowide(
                      color: sel ? const Color(0xFF7CFC00) : Colors.white60,
                      fontSize: 14, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _datePickerRow(context, 'REGISTRATION DEADLINE', _regDeadline,
            (d) => setState(() => _regDeadline = d)),
        const SizedBox(height: 10),
        _datePickerRow(context, 'START DATE', _startDate,
            (d) => setState(() => _startDate = d)),
        const SizedBox(height: 10),
        _datePickerRow(context, 'END DATE', _endDate,
            (d) => setState(() => _endDate = d)),
        const SizedBox(height: 20),
        _nextBtn(() => setState(() => _step = 2)),
      ],
    );
  }

  Widget _step3(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepTitle('STEP 3: RULES & FINAL'),
        const SizedBox(height: 14),
        TextField(
          controller: _rulesCtrl,
          minLines: 4,
          maxLines: 8,
          style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14, height: 1.5),
          decoration: const InputDecoration(
            labelText: 'Tournament Rules (optional)',
            hintText: '1. Match duration: 20 mins\n2. No slide tackles\n...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: _creating
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.emoji_events),
            label: Text('CREATE TOURNAMENT',
                style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7CFC00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _creating ? null : () => _submit(context),
          ),
        ),
      ],
    );
  }

  void _submit(BuildContext context) async {
    setState(() => _creating = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final id = TournamentService.instance.generateId();
    final tournament = Tournament(
      id: 'tour_$id',
      name: _nameCtrl.text.trim(),
      sport: _sport,
      format: _format,
      startDate: _startDate,
      endDate: _endDate,
      registrationDeadline: _regDeadline,
      maxTeams: _maxTeams,
      currentTeams: 0,
      registeredTeamIds: [],
      status: 'registration_open',
      matchSchedule: [],
      bracket: {},
      winners: [],
      createdBy: 'admin_001',
      createdAt: DateTime.now(),
      prizePool: _prizeCtrl.text.trim().isEmpty ? null : _prizeCtrl.text.trim(),
      rules: _rulesCtrl.text.trim().isEmpty ? null : _rulesCtrl.text.trim(),
      venue: _venue,
    );

    TournamentService.instance.addTournament(tournament);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${tournament.name} created!',
          style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _stepTitle(String text) {
    return Text(text,
        style: GoogleFonts.audiowide(
            color: const Color(0xFF7CFC00), fontSize: 10,
            fontWeight: FontWeight.w700, letterSpacing: 1.5));
  }

  Widget _label(String text) {
    return Text(text,
        style: GoogleFonts.audiowide(
            color: Colors.white38, fontSize: 9, letterSpacing: 1.5));
  }

  Widget _nextBtn(VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7CFC00), foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text('NEXT →',
            style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _datePickerRow(BuildContext context, String label, DateTime value,
      void Function(DateTime) onPick) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: Color(0xFF7CFC00)),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF7CFC00), size: 16),
            const SizedBox(width: 10),
            Text(label,
                style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 12)),
            const Spacer(),
            Text(
              '${value.day}/${value.month}/${value.year}',
              style: GoogleFonts.rajdhani(
                  color: const Color(0xFF7CFC00), fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }

  IconData _sportIconFromString(String sport) {
    switch (sport) {
      case 'Football': return Icons.sports_soccer;
      case 'Badminton': return Icons.sports_tennis;
      case 'Cricket': return Icons.sports_cricket;
      default: return Icons.emoji_events;
    }
  }
}
