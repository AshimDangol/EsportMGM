import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String id;
  final String userId;
  final String gamerTag;
  final String? realName;
  final String? nationality;

  Player({
    required this.id,
    required this.userId,
    required this.gamerTag,
    this.realName,
    this.nationality,
  });

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

  factory Player.fromMap(Map<String, dynamic> data, String documentId) {
    return Player(
      id: documentId,
      userId: data['userId'] ?? '',
      gamerTag: data['gamerTag'] ?? '',
      realName: data['realName'] as String?,
      nationality: data['nationality'] as String?,
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
}
