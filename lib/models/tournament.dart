import 'match.dart';

/// Represents a tournament in the system.
class Tournament {
  final String id;
  final String name;

  /// 'Football' | 'Badminton' | 'Cricket'
  final String sport;

  /// 'Single Elimination' | 'Double Elimination' | 'Round Robin' | 'Group Stage + Knockout'
  final String format;

  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final int maxTeams;
  final int currentTeams;
  final List<String> registeredTeamIds;

  /// 'upcoming' | 'registration_open' | 'ongoing' | 'completed'
  final String status;

  final List<TournamentMatch> matchSchedule;
  final Map<String, dynamic> bracket;
  final List<String> winners;
  final String createdBy;
  final DateTime createdAt;
  final String? prizePool;
  final String? rules;
  final String venue;

  const Tournament({
    required this.id,
    required this.name,
    required this.sport,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.maxTeams,
    required this.currentTeams,
    required this.registeredTeamIds,
    required this.status,
    this.matchSchedule = const [],
    this.bracket = const {},
    this.winners = const [],
    required this.createdBy,
    required this.createdAt,
    this.prizePool,
    this.rules,
    required this.venue,
  });

  bool isRegistrationOpen() =>
      status == 'registration_open' &&
      DateTime.now().isBefore(registrationDeadline);

  bool canRegister() => isRegistrationOpen() && currentTeams < maxTeams;

  List<TournamentMatch> getUpcomingMatches() => matchSchedule
      .where((m) => m.status == 'scheduled' || m.status == 'live')
      .toList()
    ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sport: json['sport'] as String? ?? 'Football',
      format: json['format'] as String? ?? 'Single Elimination',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : DateTime.now(),
      registrationDeadline: json['registrationDeadline'] != null
          ? DateTime.parse(json['registrationDeadline'] as String)
          : DateTime.now(),
      maxTeams: json['maxTeams'] as int? ?? 8,
      currentTeams: json['currentTeams'] as int? ?? 0,
      registeredTeamIds:
          List<String>.from(json['registeredTeamIds'] as List<dynamic>? ?? []),
      status: json['status'] as String? ?? 'upcoming',
      matchSchedule: (json['matchSchedule'] as List<dynamic>? ?? [])
          .map((m) => TournamentMatch.fromJson(m as Map<String, dynamic>))
          .toList(),
      bracket: Map<String, dynamic>.from(
          json['bracket'] as Map<dynamic, dynamic>? ?? {}),
      winners: List<String>.from(json['winners'] as List<dynamic>? ?? []),
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      prizePool: json['prizePool'] as String?,
      rules: json['rules'] as String?,
      venue: json['venue'] as String? ?? 'Sand Ground',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sport': sport,
      'format': format,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'maxTeams': maxTeams,
      'currentTeams': currentTeams,
      'registeredTeamIds': registeredTeamIds,
      'status': status,
      'matchSchedule': matchSchedule.map((m) => m.toJson()).toList(),
      'bracket': bracket,
      'winners': winners,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'prizePool': prizePool,
      'rules': rules,
      'venue': venue,
    };
  }

  Tournament copyWith({
    String? id,
    String? name,
    String? sport,
    String? format,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationDeadline,
    int? maxTeams,
    int? currentTeams,
    List<String>? registeredTeamIds,
    String? status,
    List<TournamentMatch>? matchSchedule,
    Map<String, dynamic>? bracket,
    List<String>? winners,
    String? createdBy,
    DateTime? createdAt,
    String? prizePool,
    String? rules,
    String? venue,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      sport: sport ?? this.sport,
      format: format ?? this.format,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      maxTeams: maxTeams ?? this.maxTeams,
      currentTeams: currentTeams ?? this.currentTeams,
      registeredTeamIds: registeredTeamIds ?? this.registeredTeamIds,
      status: status ?? this.status,
      matchSchedule: matchSchedule ?? this.matchSchedule,
      bracket: bracket ?? this.bracket,
      winners: winners ?? this.winners,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      prizePool: prizePool ?? this.prizePool,
      rules: rules ?? this.rules,
      venue: venue ?? this.venue,
    );
  }
}
