import 'package:mongo_dart/mongo_dart.dart';

enum GameEventType {
  kill,
  // In a real system, you'd have many more: e.g., movement, abilityUse, etc.
}

class GameEvent {
  final ObjectId id;
  final String matchId;
  final String playerId;
  final GameEventType eventType;
  final DateTime timestamp;
  final Map<String, dynamic> eventData; // Flexible data like { "weapon": "AK-47", "headshot": true }

  GameEvent({
    ObjectId? id,
    required this.matchId,
    required this.playerId,
    required this.eventType,
    required this.eventData,
    DateTime? timestamp,
  })  : id = id ?? ObjectId(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        '_id': id,
        'matchId': matchId,
        'playerId': playerId,
        'eventType': eventType.toString(),
        'timestamp': timestamp,
        'eventData': eventData,
      };

  factory GameEvent.fromMap(Map<String, dynamic> map) {
    return GameEvent(
      id: map['_id'] as ObjectId,
      matchId: map['matchId'] as String,
      playerId: map['playerId'] as String,
      eventType: GameEventType.values
          .firstWhere((e) => e.toString() == map['eventType'], orElse: () => GameEventType.kill),
      eventData: map['eventData'] as Map<String, dynamic>,
      timestamp: map['timestamp'] as DateTime,
    );
  }
}
