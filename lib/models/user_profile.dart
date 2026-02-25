import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user profile in the app.
/// 
/// Contains user information including authentication details,
/// preferences, and profile metadata.
class UserProfile {
  /// Unique identifier for the user (usually from Firebase Auth)
  final String id;

  /// User's full name
  final String name;

  /// User's email address
  final String email;

  /// VIT registration number
  final String registrationNumber;

  /// List of preferred sports (e.g., ['Football', 'Badminton'])
  final List<String> preferredSports;

  /// URL to the user's profile image
  final String? profileImageUrl;

  /// Timestamp when the profile was created
  final DateTime createdAt;

  /// Constructor for UserProfile
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.registrationNumber,
    required this.preferredSports,
    this.profileImageUrl,
    required this.createdAt,
  });

  /// Creates a UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      registrationNumber: json['registrationNumber'] as String? ?? '',
      preferredSports:
          List<String>.from(json['preferredSports'] as List<dynamic>? ?? []),
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'registrationNumber': registrationNumber,
      'preferredSports': preferredSports,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this UserProfile with optional field replacements
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? registrationNumber,
    List<String>? preferredSports,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      preferredSports: preferredSports ?? this.preferredSports,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Checks if a specific sport is in the user's preferences
  bool hasSportPreference(String sport) => preferredSports.contains(sport);
}
