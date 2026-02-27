import 'package:flutter/material.dart';

class UserStats {
  final String userId;
  final String name;
  final String photoUrl;
  final List<String> tags;
  final String mainPosition;
  final String favoriteGround;
  final String rollNumber;

  const UserStats({
    required this.userId,
    required this.name,
    required this.photoUrl,
    required this.tags,
    required this.mainPosition,
    required this.favoriteGround,
    this.rollNumber = '',
  });

  UserStats copyWith({
    String? userId,
    String? name,
    String? photoUrl,
    List<String>? tags,
    String? mainPosition,
    String? favoriteGround,
    String? rollNumber,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      tags: tags ?? this.tags,
      mainPosition: mainPosition ?? this.mainPosition,
      favoriteGround: favoriteGround ?? this.favoriteGround,
      rollNumber: rollNumber ?? this.rollNumber,
    );
  }

  /// Returns the primary tag (first in list)
  String getTopTag() {
    return tags.isNotEmpty ? tags.first : '';
  }

  /// Returns color based on tag sentiment (green/yellow/red flag)
  Color getVibeColor() {
    if (tags.isEmpty) return Colors.grey;

    final topTag = tags.first.toLowerCase();

    // Red flags
    if (topTag.contains('sledger') ||
        topTag.contains('toxic') ||
        topTag.contains('bad mouth') ||
        topTag.contains('rage quitter')) {
      return const Color(0xFFFF1744);
    }

    // Yellow flags
    if (topTag.contains('late') ||
        topTag.contains('ball hog') ||
        topTag.contains('excuse') ||
        topTag.contains('sweaty')) {
      return const Color(0xFFFFC400);
    }

    // Green flags (positive)
    return const Color(0xFF00C853);
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String,
      tags: List<String>.from(json['tags'] as List),
      mainPosition: json['mainPosition'] as String,
      favoriteGround: json['favoriteGround'] as String,
      rollNumber: (json['rollNumber'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'photoUrl': photoUrl,
      'tags': tags,
      'mainPosition': mainPosition,
      'favoriteGround': favoriteGround,
      'rollNumber': rollNumber,
    };
  }
}

/// Returns color for a specific tag
Color tagColor(String tag) {
  final t = tag.toLowerCase();

  // Positive tags (green)
  if (t.contains('team player') ||
      t.contains('clutch') ||
      t.contains('early bird') ||
      t.contains('consistent') ||
      t.contains('no cap')) {
    return const Color(0xFF00C853);
  }

  // Captain/special (gold)
  if (t.contains('captain') || t.contains('built different')) {
    return const Color(0xFFFFD700);
  }

  // Negative tags (red)
  if (t.contains('sledger') ||
      t.contains('bad mouth') ||
      t.contains('toxic') ||
      t.contains('cooked')) {
    return const Color(0xFFFF1744);
  }

  // Warning tags (orange)
  if (t.contains('rage') ||
      t.contains('ball hog') ||
      t.contains('excuse') ||
      t.contains('sweaty')) {
    return const Color(0xFFFF6E40);
  }

  // Late/unreliable (yellow)
  if (t.contains('late')) {
    return const Color(0xFFFFC400);
  }

  // Special Gen-Z tags
  if (t.contains('carrying')) return const Color(0xFFAA00FF);
  if (t.contains('mid')) return const Color(0xFF9E9E9E);
  if (t.contains('chill')) return const Color(0xFF00BFA5);
  if (t.contains('npc')) return const Color(0xFF757575);

  // Default blue
  return const Color(0xFF2979FF);
}
