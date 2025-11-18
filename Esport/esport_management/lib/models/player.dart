import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

@immutable
class Player {
  final String id;
  final String userId; // Link to the global user account
  final String gamerTag;
  final String? realName; // Optional
  final String? nationality;

  const Player({
    required this.id,
    required this.userId,
    required this.gamerTag,
    this.realName,
    this.nationality,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: (map['_id'] as ObjectId).toHexString(),
      userId: map['userId'] as String? ?? '',
      gamerTag: map['gamerTag'] as String? ?? '',
      realName: map['realName'] as String?,
      nationality: map['nationality'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'gamerTag': gamerTag,
      'realName': realName,
      'nationality': nationality,
    };
  }

  Player copyWith({
    String? id,
    String? userId,
    String? gamerTag,
    String? realName,
    String? nationality,
  }) {
    return Player(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gamerTag: gamerTag ?? this.gamerTag,
      realName: realName ?? this.realName,
      nationality: nationality ?? this.nationality,
    );
  }
}
