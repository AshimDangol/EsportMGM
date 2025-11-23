import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum PlayerStatus {
  active,
  inactive,
  banned,
}

@immutable
class Player {
  final String id;
  final String userId;
  final String gamerTag;
  final String? realName;
  final String? nationality;
  final PlayerStatus status;
  final String? clanId;
  final List<String> favoriteGames;

  const Player({
    required this.id,
    required this.userId,
    required this.gamerTag,
    this.realName,
    this.nationality,
    this.status = PlayerStatus.active,
    this.clanId,
    this.favoriteGames = const [],
  });

  Player copyWith({
    String? id,
    String? userId,
    String? gamerTag,
    String? realName,
    String? nationality,
    PlayerStatus? status,
    String? clanId,
    List<String>? favoriteGames,
  }) {
    return Player(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gamerTag: gamerTag ?? this.gamerTag,
      realName: realName ?? this.realName,
      nationality: nationality ?? this.nationality,
      status: status ?? this.status,
      clanId: clanId ?? this.clanId,
      favoriteGames: favoriteGames ?? this.favoriteGames,
    );
  }

  factory Player.fromMap(Map<String, dynamic> data, String documentId) {
    return Player(
      id: documentId,
      userId: data['userId'] ?? '',
      gamerTag: data['gamerTag'] ?? '',
      realName: data['realName'] as String?,
      nationality: data['nationality'] as String?,
      status: PlayerStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => PlayerStatus.active,
      ),
      clanId: data['clanId'] as String?,
      favoriteGames: List<String>.from(data['favoriteGames'] ?? []),
    );
  }

  factory Player.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Player(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      gamerTag: data['gamerTag'] ?? '',
      realName: data['realName'] as String?,
      nationality: data['nationality'] as String?,
      status: PlayerStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => PlayerStatus.active,
      ),
      clanId: data['clanId'] as String?,
      favoriteGames: List<String>.from(data['favoriteGames'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'gamerTag': gamerTag,
      'realName': realName,
      'nationality': nationality,
      'status': status.toString(),
      'clanId': clanId,
      'favoriteGames': favoriteGames,
    };
  }

  @override
  String toString() {
    return 'Player(id: $id, userId: $userId, gamerTag: $gamerTag, realName: $realName, nationality: $nationality, status: $status, clanId: $clanId, favoriteGames: $favoriteGames)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Player &&
      other.id == id &&
      other.userId == userId &&
      other.gamerTag == gamerTag &&
      other.realName == realName &&
      other.nationality == nationality &&
      other.status == status &&
      other.clanId == clanId &&
      listEquals(other.favoriteGames, favoriteGames);
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      gamerTag.hashCode ^
      realName.hashCode ^
      nationality.hashCode ^
      status.hashCode ^
      clanId.hashCode ^
      favoriteGames.hashCode;
  }
}
