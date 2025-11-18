import 'package:flutter/foundation.dart';

enum UserRole {
  admin,
  teamManager,
  player,
  referee,
  coach,
  host,
  analyst,
  spectator, // Default role
}

@immutable
class User {
  final String id;
  final String email;
  final UserRole role;

  const User({
    required this.id,
    required this.email,
    this.role = UserRole.spectator,
  });

  // Updated factory to work with Firestore
  factory User.fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id, // Use the document ID passed from Firestore
      email: map['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == "UserRole.${map['role']}", // Correctly match enum string
        orElse: () => UserRole.spectator,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role.name, // Use .name for storing the enum value
    };
  }
}
