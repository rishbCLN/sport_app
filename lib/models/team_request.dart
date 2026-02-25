import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a team request for a specific sport.
/// 
/// This model contains all information about a player looging for teammates
/// or a team looking for additional players for a specific sport and ground.
class TeamRequest {
  /// Unique identifier for the team request
  final String id;

  /// Sport type (e.g., 'Football', 'Badminton', 'Cricket')
  final String sport;

  /// Ground number where the game will be played (1-5)
  final int groundNumber;

  /// Total number of players needed
  final int playersNeeded;

  /// Current number of players who have joined
  final int currentPlayers;

  /// List of player IDs who have joined this request
  final List<String> playerIds;

  /// ID of the user who created this request
  final String creatorId;

  /// Timestamp when the request was created
  final DateTime createdAt;

  /// Status of the request ('active', 'completed', 'cancelled')
  final String status;

  /// Constructor for TeamRequest
  const TeamRequest({
    required this.id,
    required this.sport,
    required this.groundNumber,
    required this.playersNeeded,
    required this.currentPlayers,
    required this.playerIds,
    required this.creatorId,
    required this.createdAt,
    required this.status,
  });

  /// Creates a TeamRequest from a Firestore document snapshot
  factory TeamRequest.fromJson(Map<String, dynamic> json) {
    return TeamRequest(
      id: json['id'] as String? ?? '',
      sport: json['sport'] as String? ?? '',
      groundNumber: json['groundNumber'] as int? ?? 0,
      playersNeeded: json['playersNeeded'] as int? ?? 0,
      currentPlayers: json['currentPlayers'] as int? ?? 0,
      playerIds: List<String>.from(json['playerIds'] as List<dynamic>? ?? []),
      creatorId: json['creatorId'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: json['status'] as String? ?? 'active',
    );
  }

  /// Converts TeamRequest to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sport': sport,
      'groundNumber': groundNumber,
      'playersNeeded': playersNeeded,
      'currentPlayers': currentPlayers,
      'playerIds': playerIds,
      'creatorId': creatorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  /// Creates a copy of this TeamRequest with optional field replacements
  TeamRequest copyWith({
    String? id,
    String? sport,
    int? groundNumber,
    int? playersNeeded,
    int? currentPlayers,
    List<String>? playerIds,
    String? creatorId,
    DateTime? createdAt,
    String? status,
  }) {
    return TeamRequest(
      id: id ?? this.id,
      sport: sport ?? this.sport,
      groundNumber: groundNumber ?? this.groundNumber,
      playersNeeded: playersNeeded ?? this.playersNeeded,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      playerIds: playerIds ?? this.playerIds,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  /// Returns the number of players still needed
  int get playersStillNeeded => playersNeeded - currentPlayers;

  /// Returns the progress as a percentage (0.0 - 1.0)
  double get progress => currentPlayers / playersNeeded;

  /// Returns whether the team is full
  bool get isFull => currentPlayers >= playersNeeded;
}
