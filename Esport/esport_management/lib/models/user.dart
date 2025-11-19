import 'package:flutter/foundation.dart';

// Roles as defined in the feature list
enum UserRole {
  admin,       // Full control
  coach,       // Coach/Manager
  player,      // Player
  viewer,      // Viewer/Fan (Default)
}

@immutable
class User {
  final String id;
  final String email;
  final UserRole role;
  final String theme;

  const User({
    required this.id,
    required this.email,
    this.role = UserRole.viewer, // Default role is Viewer
    this.theme = 'system',
  });

  factory User.fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      email: map['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.viewer, // Safely default to viewer
      ),
      theme: map['theme'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role.name, // Store the role as a string (e.g., 'admin')
      'theme': theme,
    };
  }

  User copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? theme,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      theme: theme ?? this.theme,
    );
  }
}
