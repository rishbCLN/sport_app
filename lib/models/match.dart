/// Represents a single match within a tournament.
class TournamentMatch {
  final String id;
  final String tournamentId;
  final int matchNumber;
  final String round;
  final String team1Id;
  final String team2Id;
  final String team1Name;
  final String team2Name;
  final int? team1Score;
  final int? team2Score;
  final String? winnerId;
  final DateTime scheduledTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;

  /// 'scheduled' | 'live' | 'completed' | 'postponed'
  final String status;
  final String ground;

  const TournamentMatch({
    required this.id,
    required this.tournamentId,
    required this.matchNumber,
    required this.round,
    required this.team1Id,
    required this.team2Id,
    required this.team1Name,
    required this.team2Name,
    this.team1Score,
    this.team2Score,
    this.winnerId,
    required this.scheduledTime,
    this.actualStartTime,
    this.actualEndTime,
    required this.status,
    required this.ground,
  });

  bool isLive() => status == 'live';

  bool isCompleted() => status == 'completed';

  String? getWinnerName() {
    if (winnerId == null) return null;
    if (winnerId == team1Id) return team1Name;
    if (winnerId == team2Id) return team2Name;
    return null;
  }

  factory TournamentMatch.fromJson(Map<String, dynamic> json) {
    return TournamentMatch(
      id: json['id'] as String? ?? '',
      tournamentId: json['tournamentId'] as String? ?? '',
      matchNumber: json['matchNumber'] as int? ?? 0,
      round: json['round'] as String? ?? '',
      team1Id: json['team1Id'] as String? ?? '',
      team2Id: json['team2Id'] as String? ?? '',
      team1Name: json['team1Name'] as String? ?? 'TBD',
      team2Name: json['team2Name'] as String? ?? 'TBD',
      team1Score: json['team1Score'] as int?,
      team2Score: json['team2Score'] as int?,
      winnerId: json['winnerId'] as String?,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'] as String)
          : DateTime.now(),
      actualStartTime: json['actualStartTime'] != null
          ? DateTime.parse(json['actualStartTime'] as String)
          : null,
      actualEndTime: json['actualEndTime'] != null
          ? DateTime.parse(json['actualEndTime'] as String)
          : null,
      status: json['status'] as String? ?? 'scheduled',
      ground: json['ground'] as String? ?? 'Sand Ground',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'matchNumber': matchNumber,
      'round': round,
      'team1Id': team1Id,
      'team2Id': team2Id,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'winnerId': winnerId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'actualStartTime': actualStartTime?.toIso8601String(),
      'actualEndTime': actualEndTime?.toIso8601String(),
      'status': status,
      'ground': ground,
    };
  }

  TournamentMatch copyWith({
    String? id,
    String? tournamentId,
    int? matchNumber,
    String? round,
    String? team1Id,
    String? team2Id,
    String? team1Name,
    String? team2Name,
    int? team1Score,
    int? team2Score,
    String? winnerId,
    DateTime? scheduledTime,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    String? status,
    String? ground,
  }) {
    return TournamentMatch(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      matchNumber: matchNumber ?? this.matchNumber,
      round: round ?? this.round,
      team1Id: team1Id ?? this.team1Id,
      team2Id: team2Id ?? this.team2Id,
      team1Name: team1Name ?? this.team1Name,
      team2Name: team2Name ?? this.team2Name,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      winnerId: winnerId ?? this.winnerId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      status: status ?? this.status,
      ground: ground ?? this.ground,
    );
  }
}
