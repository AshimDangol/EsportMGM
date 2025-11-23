import 'package:flutter/foundation.dart';

// Roles as defined in the feature list
enum UserRole {
  admin,       // Full control (Default)
  tournament_organizer,
  clan_leader,
}

@immutable
class User {
  final String id;
  final String email;
  final UserRole role;
  final String theme;
  final String? photoUrl;
  final List<String> friendIds;

  const User({
    required this.id,
    required this.email,
    this.role = UserRole.admin, // Default role is Admin
    this.theme = 'system',
    this.photoUrl,
    this.friendIds = const [],
  });

  factory User.fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      email: map['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.admin, // Safely default to admin
      ),
      theme: map['theme'] as String? ?? 'system',
      photoUrl: map['photoUrl'] as String?,
      friendIds: List<String>.from(map['friendIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role.name, // Store the role as a string
      'theme': theme,
      'photoUrl': photoUrl,
      'friendIds': friendIds,
    };
  }

  User copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? theme,
    String? photoUrl,
    List<String>? friendIds,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      theme: theme ?? this.theme,
      photoUrl: photoUrl ?? this.photoUrl,
      friendIds: friendIds ?? this.friendIds,
    );
  }
}
