import '../models/tournament.dart';
import '../models/match.dart';
import '../models/tournament_team.dart';

/// Central mock data store for the tournament system.
/// Acts as an in-memory database for the prototype.
class TournamentService {
  TournamentService._();
  static final TournamentService instance = TournamentService._();

  // ─── In-memory stores ────────────────────────────────────────────────────
  List<Tournament> _tournaments = [];
  List<TournamentTeam> _teams = [];

  // ─── Listeners ───────────────────────────────────────────────────────────
  final List<void Function()> _listeners = [];

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);
  void _notify() {
    for (final l in _listeners) {
      l();
    }
  }

  // ─── Seed demo data ──────────────────────────────────────────────────────
  void seedDemoData() {
    if (_tournaments.isNotEmpty) return;

    final now = DateTime.now();

    // --- Demo teams ---
    final demoTeams = [
      TournamentTeam(
        id: 'team_a', name: 'A Block Strikers', captainId: 'u1',
        captainName: 'Arjun Kumar', playerIds: ['u1', 'u2', 'u3', 'u4', 'u5', 'u6'],
        playerNames: ['Arjun Kumar', 'Rahul Singh', 'Karan M', 'Vijay P', 'Ravi T', 'Suresh B'],
        tournamentId: 'tour_football_2024', hostelBlock: 'A Block',
        wins: 2, losses: 0, goalsScored: 5, goalsConceded: 1, points: 6,
      ),
      TournamentTeam(
        id: 'team_b', name: 'B Block United', captainId: 'u7',
        captainName: 'Priya Nair', playerIds: ['u7', 'u8', 'u9', 'u10', 'u11', 'u12'],
        playerNames: ['Priya Nair', 'Sita R', 'Anita J', 'Deepa K', 'Meena S', 'Latha V'],
        tournamentId: 'tour_football_2024', hostelBlock: 'B Block',
        wins: 1, losses: 1, goalsScored: 3, goalsConceded: 3, points: 3,
      ),
      TournamentTeam(
        id: 'team_c', name: 'C Block Warriors', captainId: 'u13',
        captainName: 'Dev Sharma', playerIds: ['u13','u14','u15','u16','u17','u18'],
        playerNames: ['Dev Sharma', 'Arun B', 'Nikhil C', 'Rohit D', 'Sankar E', 'Tarun F'],
        tournamentId: 'tour_football_2024', hostelBlock: 'C Block',
        wins: 1, losses: 1, goalsScored: 2, goalsConceded: 2, points: 3,
      ),
      TournamentTeam(
        id: 'team_d', name: 'D Block FC', captainId: 'u19',
        captainName: 'Manu Raj', playerIds: ['u19','u20','u21','u22','u23','u24'],
        playerNames: ['Manu Raj', 'Vinod G', 'Pranav H', 'Ashok I', 'Balaji J', 'Chandru K'],
        tournamentId: 'tour_football_2024', hostelBlock: 'D Block',
        wins: 0, losses: 2, goalsScored: 1, goalsConceded: 5, points: 0,
      ),
      TournamentTeam(
        id: 'team_e', name: 'E Block Eagles', captainId: 'u25',
        captainName: 'Riya Patel', playerIds: ['u25','u26','u27','u28','u29','u30'],
        playerNames: ['Riya Patel', 'Sneha L', 'Kavya M', 'Pooja N', 'Divya O', 'Hema P'],
        tournamentId: 'tour_football_2024', hostelBlock: 'E Block',
        wins: 0, losses: 0, goalsScored: 0, goalsConceded: 0, points: 0,
      ),
      TournamentTeam(
        id: 'team_f', name: 'F Block Phoenix', captainId: 'u31',
        captainName: 'Kiran Das', playerIds: ['u31','u32','u33','u34','u35','u36'],
        playerNames: ['Kiran Das', 'Aditya Q', 'Bharat R', 'Chandra S', 'Dinesh T', 'Eswar U'],
        tournamentId: 'tour_football_2024', hostelBlock: 'F Block',
        wins: 0, losses: 0, goalsScored: 0, goalsConceded: 0, points: 0,
      ),
      TournamentTeam(
        id: 'team_g', name: 'G Block Gladiators', captainId: 'u37',
        captainName: 'Nisha V', playerIds: ['u37','u38','u39','u40','u41','u42'],
        playerNames: ['Nisha V', 'Sonu W', 'Tara X', 'Uma Y', 'Vani Z', 'Wini AA'],
        tournamentId: 'tour_football_2024', hostelBlock: 'G Block',
        wins: 0, losses: 0, goalsScored: 0, goalsConceded: 0, points: 0,
      ),
      TournamentTeam(
        id: 'team_h', name: 'H Block Heroes', captainId: 'u43',
        captainName: 'Ajay Rao', playerIds: ['u43','u44','u45','u46','u47','u48'],
        playerNames: ['Ajay Rao', 'Binu BB', 'Cinu CC', 'Dinu DD', 'Einu EE', 'Finu FF'],
        tournamentId: 'tour_football_2024', hostelBlock: 'H Block',
        wins: 0, losses: 0, goalsScored: 0, goalsConceded: 0, points: 0,
      ),
    ];

    // --- Demo matches ---
    final demoMatches = [
      TournamentMatch(
        id: 'm1', tournamentId: 'tour_football_2024', matchNumber: 1,
        round: 'Quarter Final', team1Id: 'team_a', team2Id: 'team_b',
        team1Name: 'A Block Strikers', team2Name: 'B Block United',
        team1Score: 3, team2Score: 1, winnerId: 'team_a',
        scheduledTime: now.subtract(const Duration(days: 2)),
        actualStartTime: now.subtract(const Duration(days: 2)),
        actualEndTime: now.subtract(const Duration(days: 2, minutes: -20)),
        status: 'completed', ground: 'Sand Ground',
      ),
      TournamentMatch(
        id: 'm2', tournamentId: 'tour_football_2024', matchNumber: 2,
        round: 'Quarter Final', team1Id: 'team_c', team2Id: 'team_d',
        team1Name: 'C Block Warriors', team2Name: 'D Block FC',
        team1Score: 2, team2Score: 0, winnerId: 'team_c',
        scheduledTime: now.subtract(const Duration(days: 2)),
        actualStartTime: now.subtract(const Duration(days: 2)),
        actualEndTime: now.subtract(const Duration(days: 2, minutes: -20)),
        status: 'completed', ground: 'Hard Ground',
      ),
      TournamentMatch(
        id: 'm3', tournamentId: 'tour_football_2024', matchNumber: 3,
        round: 'Quarter Final', team1Id: 'team_e', team2Id: 'team_f',
        team1Name: 'E Block Eagles', team2Name: 'F Block Phoenix',
        team1Score: 1, team2Score: 2,
        scheduledTime: now.subtract(const Duration(hours: 1)),
        actualStartTime: now.subtract(const Duration(hours: 1)),
        status: 'live', ground: 'Sand Ground',
        winnerId: null,
      ),
      TournamentMatch(
        id: 'm4', tournamentId: 'tour_football_2024', matchNumber: 4,
        round: 'Quarter Final', team1Id: 'team_g', team2Id: 'team_h',
        team1Name: 'G Block Gladiators', team2Name: 'H Block Heroes',
        scheduledTime: now.add(const Duration(hours: 2)),
        status: 'scheduled', ground: 'Hard Ground',
      ),
      TournamentMatch(
        id: 'm5', tournamentId: 'tour_football_2024', matchNumber: 5,
        round: 'Semi Final', team1Id: 'team_a', team2Id: 'team_c',
        team1Name: 'A Block Strikers', team2Name: 'C Block Warriors',
        scheduledTime: now.add(const Duration(days: 3)),
        status: 'scheduled', ground: 'Sand Ground',
      ),
      TournamentMatch(
        id: 'm6', tournamentId: 'tour_football_2024', matchNumber: 6,
        round: 'Semi Final', team1Id: 'TBD', team2Id: 'TBD',
        team1Name: 'TBD', team2Name: 'TBD',
        scheduledTime: now.add(const Duration(days: 3)),
        status: 'scheduled', ground: 'Hard Ground',
      ),
      TournamentMatch(
        id: 'm7', tournamentId: 'tour_football_2024', matchNumber: 7,
        round: 'Final', team1Id: 'TBD', team2Id: 'TBD',
        team1Name: 'TBD', team2Name: 'TBD',
        scheduledTime: now.add(const Duration(days: 7)),
        status: 'scheduled', ground: 'Sand Ground',
      ),
    ];

    _teams = demoTeams;

    _tournaments = [
      Tournament(
        id: 'tour_football_2024',
        name: 'VIT Inter-Hostel Football Cup 2024',
        sport: 'Football',
        format: 'Single Elimination',
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 8)),
        registrationDeadline: now.subtract(const Duration(days: 5)),
        maxTeams: 8,
        currentTeams: 8,
        registeredTeamIds: demoTeams.map((t) => t.id).toList(),
        status: 'ongoing',
        matchSchedule: demoMatches,
        bracket: {},
        winners: [],
        createdBy: 'admin_001',
        createdAt: now.subtract(const Duration(days: 10)),
        prizePool: '₹5,000 prize pool',
        rules:
            '1. Each match is 20 mins (10 min halves).\n2. Standard 7-a-side rules apply.\n3. No slide tackles allowed.\n4. Yellow card = 5 min suspension.\n5. Red card = disqualified from match.',
        venue: 'Sand Ground',
      ),
      Tournament(
        id: 'tour_badminton_2024',
        name: 'VIT Badminton Singles Open',
        sport: 'Badminton',
        format: 'Round Robin',
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 12)),
        registrationDeadline: now.add(const Duration(days: 3)),
        maxTeams: 16,
        currentTeams: 9,
        registeredTeamIds: [],
        status: 'registration_open',
        matchSchedule: [],
        bracket: {},
        winners: [],
        createdBy: 'admin_001',
        createdAt: now.subtract(const Duration(days: 2)),
        prizePool: '₹2,000 prize pool',
        rules: '1. Best of 3 sets format.\n2. 21 points per set.\n3. 2-point advantage rule applies.',
        venue: 'Indoor Badminton Court',
      ),
      Tournament(
        id: 'tour_cricket_2024',
        name: 'VIT T10 Cricket Championship',
        sport: 'Cricket',
        format: 'Group Stage + Knockout',
        startDate: now.add(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 22)),
        registrationDeadline: now.add(const Duration(days: 10)),
        maxTeams: 16,
        currentTeams: 4,
        registeredTeamIds: [],
        status: 'registration_open',
        matchSchedule: [],
        bracket: {},
        winners: [],
        createdBy: 'admin_001',
        createdAt: now.subtract(const Duration(days: 1)),
        prizePool: '₹8,000 prize pool',
        rules:
            '1. T10 format - 10 overs per innings.\n2. Max 3 overs per bowler.\n3. Free hit on no-ball.\n4. Power play: First 3 overs.',
        venue: 'Cricket Ground',
      ),
    ];
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  List<Tournament> getTournaments() => List.unmodifiable(_tournaments);

  Tournament? getTournamentById(String id) {
    try {
      return _tournaments.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void addTournament(Tournament tournament) {
    _tournaments = [..._tournaments, tournament];
    _notify();
  }

  void updateTournament(Tournament tournament) {
    _tournaments = _tournaments
        .map((t) => t.id == tournament.id ? tournament : t)
        .toList();
    _notify();
  }

  void deleteTournament(String id) {
    _tournaments = _tournaments.where((t) => t.id != id).toList();
    _notify();
  }

  // ─── Teams ────────────────────────────────────────────────────────────────

  List<TournamentTeam> getTeamsForTournament(String tournamentId) =>
      _teams.where((t) => t.tournamentId == tournamentId).toList();

  TournamentTeam? getTeamById(String id) {
    try {
      return _teams.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void addTeam(TournamentTeam team) {
    _teams = [..._teams, team];
    final tournament = getTournamentById(team.tournamentId);
    if (tournament != null) {
      updateTournament(tournament.copyWith(
        currentTeams: tournament.currentTeams + 1,
        registeredTeamIds: [...tournament.registeredTeamIds, team.id],
      ));
    }
    _notify();
  }

  // ─── Matches ──────────────────────────────────────────────────────────────

  void updateMatch(TournamentMatch updatedMatch) {
    final tournament =
        getTournamentById(updatedMatch.tournamentId);
    if (tournament == null) return;
    final updatedSchedule = tournament.matchSchedule
        .map((m) => m.id == updatedMatch.id ? updatedMatch : m)
        .toList();
    updateTournament(tournament.copyWith(matchSchedule: updatedSchedule));
  }

  // ─── Generate unique IDs ──────────────────────────────────────────────────

  String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      (DateTime.now().microsecondsSinceEpoch % 1000).toString();
}
