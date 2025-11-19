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

  const Player({
    required this.id,
    required this.userId,
    required this.gamerTag,
    this.realName,
    this.nationality,
    this.status = PlayerStatus.active,
  });

  Player copyWith({
    String? id,
    String? userId,
    String? gamerTag,
    String? realName,
    String? nationality,
    PlayerStatus? status,
  }) {
    return Player(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gamerTag: gamerTag ?? this.gamerTag,
      realName: realName ?? this.realName,
      nationality: nationality ?? this.nationality,
      status: status ?? this.status,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'gamerTag': gamerTag,
      'realName': realName,
      'nationality': nationality,
      'status': status.toString(),
    };
  }

  @override
  String toString() {
    return 'Player(id: $id, userId: $userId, gamerTag: $gamerTag, realName: $realName, nationality: $nationality, status: $status)';
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
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        gamerTag.hashCode ^
        realName.hashCode ^
        nationality.hashCode ^
        status.hashCode;
  }
}