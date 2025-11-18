import 'package:mongo_dart/mongo_dart.dart';

class PlayerProfile {
  final ObjectId id;
  final String userId; // Links to the main user account
  final String inGameName;
  final Map<String, dynamic> stats; // e.g., {'kills': 1500, 'deaths': 1200}
  final List<String> achievements;

  PlayerProfile({
    ObjectId? id,
    required this.userId,
    required this.inGameName,
    this.stats = const {},
    this.achievements = const [],
  }) : id = id ?? ObjectId();

  factory PlayerProfile.fromMap(Map<String, dynamic> map) {
    return PlayerProfile(
      id: map['_id'] as ObjectId?,
      userId: map['userId'] as String,
      inGameName: map['inGameName'] as String,
      stats: Map<String, dynamic>.from(map['stats'] ?? {}),
      achievements: List<String>.from(map['achievements'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'inGameName': inGameName,
      'stats': stats,
      'achievements': achievements,
    };
  }
}
