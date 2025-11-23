import 'package:esport_mgm/models/player_role.dart';
import 'package:flutter/foundation.dart';

@immutable
class Clan {
  final String id;
  final String name;
  final String tag;
  final String ownerId;
  final List<String> memberIds;
  final Map<String, PlayerRole> roles; // Maps userId to their role in the clan
  final List<String> teamIds;

  const Clan({
    required this.id,
    required this.name,
    required this.tag,
    required this.ownerId,
    this.memberIds = const [],
    this.roles = const {},
    this.teamIds = const [],
  });

  factory Clan.fromMap(String id, Map<String, dynamic> data) {
    return Clan(
      id: id,
      name: data['name'] as String? ?? '',
      tag: data['tag'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      roles: (data['roles'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, PlayerRole.values.firstWhere((e) => e.name == value, orElse: () => PlayerRole.flex)),
      ),
      teamIds: List<String>.from(data['teamIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tag': tag,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'roles': roles.map((key, value) => MapEntry(key, value.name)),
      'teamIds': teamIds,
    };
  }
}
