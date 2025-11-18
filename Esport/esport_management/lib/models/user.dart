import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

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
  // Password hash should be stored, but the model only needs to care about the user data

  const User({
    required this.id,
    required this.email,
    this.role = UserRole.spectator,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: (map['_id'] as ObjectId).toHexString(),
      email: map['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == map['role'],
        orElse: () => UserRole.spectator,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role.toString(),
      // Never store plain text password in the database
    };
  }
}
