/// Represents a team registered for a tournament.
class TournamentTeam {
  final String id;
  final String name;
  final String captainId;
  final String captainName;
  final List<String> playerIds;
  final List<String> playerNames;
  final String tournamentId;
  final String? hostelBlock;
  final int wins;
  final int losses;
  final int goalsScored;
  final int goalsConceded;
  final int points;

  const TournamentTeam({
    required this.id,
    required this.name,
    required this.captainId,
    required this.captainName,
    required this.playerIds,
    required this.playerNames,
    required this.tournamentId,
    this.hostelBlock,
    this.wins = 0,
    this.losses = 0,
    this.goalsScored = 0,
    this.goalsConceded = 0,
    this.points = 0,
  });

  int get goalDifference => goalsScored - goalsConceded;
  int get gamesPlayed => wins + losses;

  factory TournamentTeam.fromJson(Map<String, dynamic> json) {
    return TournamentTeam(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      captainId: json['captainId'] as String? ?? '',
      captainName: json['captainName'] as String? ?? '',
      playerIds:
          List<String>.from(json['playerIds'] as List<dynamic>? ?? []),
      playerNames:
          List<String>.from(json['playerNames'] as List<dynamic>? ?? []),
      tournamentId: json['tournamentId'] as String? ?? '',
      hostelBlock: json['hostelBlock'] as String?,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      goalsScored: json['goalsScored'] as int? ?? 0,
      goalsConceded: json['goalsConceded'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'captainId': captainId,
      'captainName': captainName,
      'playerIds': playerIds,
      'playerNames': playerNames,
      'tournamentId': tournamentId,
      'hostelBlock': hostelBlock,
      'wins': wins,
      'losses': losses,
      'goalsScored': goalsScored,
      'goalsConceded': goalsConceded,
      'points': points,
    };
  }

  TournamentTeam copyWith({
    String? id,
    String? name,
    String? captainId,
    String? captainName,
    List<String>? playerIds,
    List<String>? playerNames,
    String? tournamentId,
    String? hostelBlock,
    int? wins,
    int? losses,
    int? goalsScored,
    int? goalsConceded,
    int? points,
  }) {
    return TournamentTeam(
      id: id ?? this.id,
      name: name ?? this.name,
      captainId: captainId ?? this.captainId,
      captainName: captainName ?? this.captainName,
      playerIds: playerIds ?? this.playerIds,
      playerNames: playerNames ?? this.playerNames,
      tournamentId: tournamentId ?? this.tournamentId,
      hostelBlock: hostelBlock ?? this.hostelBlock,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      goalsScored: goalsScored ?? this.goalsScored,
      goalsConceded: goalsConceded ?? this.goalsConceded,
      points: points ?? this.points,
    );
  }
}
