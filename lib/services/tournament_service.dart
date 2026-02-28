import '../models/tournament.dart';
import '../models/match.dart';
import '../models/tournament_team.dart';

/// Lightweight in-memory tournament store.
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
