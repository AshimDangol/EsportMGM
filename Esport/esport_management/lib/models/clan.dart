import 'package:flutter/foundation.dart';

enum ClanPrivacy {
  public,
  private,
  closed,
}

@immutable
class Clan {
  final String id;
  final String name;
  final String tag;
  final String ownerId; // This is the main Admin
  final List<String> coAdminIds;
  final List<String> memberIds;
  final List<String> pendingMemberIds;
  final List<String> teamIds;
  final String? logoUrl;
  final String joinCode;
  final ClanPrivacy privacy;

  const Clan({
    required this.id,
    required this.name,
    required this.tag,
    required this.ownerId,
    required this.joinCode,
    this.coAdminIds = const [],
    this.memberIds = const [],
    this.pendingMemberIds = const [],
    this.teamIds = const [],
    this.logoUrl,
    this.privacy = ClanPrivacy.public,
  });

  factory Clan.fromMap(String id, Map<String, dynamic> data) {
    return Clan(
      id: id,
      name: data['name'] as String? ?? '',
      tag: data['tag'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      joinCode: data['joinCode'] as String? ?? '',
      coAdminIds: List<String>.from(data['coAdminIds'] ?? []),
      memberIds: List<String>.from(data['memberIds'] ?? []),
      pendingMemberIds: List<String>.from(data['pendingMemberIds'] ?? []),
      teamIds: List<String>.from(data['teamIds'] ?? []),
      logoUrl: data['logoUrl'] as String?,
      privacy: ClanPrivacy.values.firstWhere((e) => e.name == data['privacy'], orElse: () => ClanPrivacy.public),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tag': tag,
      'ownerId': ownerId,
      'joinCode': joinCode,
      'coAdminIds': coAdminIds,
      'memberIds': memberIds,
      'pendingMemberIds': pendingMemberIds,
      'teamIds': teamIds,
      'logoUrl': logoUrl,
      'privacy': privacy.name,
    };
  }

  Clan copyWith({
    String? id,
    String? name,
    String? tag,
    String? ownerId,
    String? joinCode,
    List<String>? coAdminIds,
    List<String>? memberIds,
    List<String>? pendingMemberIds,
    List<String>? teamIds,
    String? logoUrl,
    ClanPrivacy? privacy,
  }) {
    return Clan(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      ownerId: ownerId ?? this.ownerId,
      joinCode: joinCode ?? this.joinCode,
      coAdminIds: coAdminIds ?? this.coAdminIds,
      memberIds: memberIds ?? this.memberIds,
      pendingMemberIds: pendingMemberIds ?? this.pendingMemberIds,
      teamIds: teamIds ?? this.teamIds,
      logoUrl: logoUrl ?? this.logoUrl,
      privacy: privacy ?? this.privacy,
    );
  }
}
