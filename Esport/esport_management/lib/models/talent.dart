import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum TalentRole {
  coach,
  analyst,
  referee,
  caster,
  host,
}

@immutable
class Talent {
  final String id;
  final String name;
  final TalentRole role;
  final String? email;
  final String? twitter;
  final String creatorId;

  const Talent({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.twitter,
    required this.creatorId,
  });

  factory Talent.fromMap(String id, Map<String, dynamic> data) {
    return Talent(
      id: id,
      name: data['name'] as String? ?? '',
      role: TalentRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => TalentRole.caster,
      ),
      email: data['email'] as String?,
      twitter: data['twitter'] as String?,
      creatorId: data['creatorId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role.name,
      'email': email,
      'twitter': twitter,
      'creatorId': creatorId,
    };
  }
}
