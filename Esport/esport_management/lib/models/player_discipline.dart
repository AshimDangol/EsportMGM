import 'package:mongo_dart/mongo_dart.dart';

enum PlayerStatus {
  active,
  suspended,
  banned,
}

class DisciplinaryAction {
  final ObjectId id;
  final PlayerStatus status;
  final String reason;
  final DateTime timestamp;
  final String performedBy; // Admin/moderator user ID

  DisciplinaryAction({
    required this.status,
    required this.reason,
    required this.performedBy,
  })  : id = ObjectId(),
        timestamp = DateTime.now();

  Map<String, dynamic> toMap() => {
        '_id': id,
        'status': status.toString(),
        'reason': reason,
        'timestamp': timestamp,
        'performedBy': performedBy,
      };

  factory DisciplinaryAction.fromMap(Map<String, dynamic> map) {
    return DisciplinaryAction(
      status: PlayerStatus.values
          .firstWhere((e) => e.toString() == map['status'], orElse: () => PlayerStatus.active),
      reason: map['reason'] as String,
      performedBy: map['performedBy'] as String,
    ); // Note: id and timestamp are reconstructed from the map if needed, but are final here.
  }
}

class PlayerDiscipline {
  final ObjectId id;
  final String playerId;
  PlayerStatus currentStatus;
  DateTime? suspensionEndDate;
  final List<DisciplinaryAction> history;

  PlayerDiscipline({
    required this.playerId,
    this.currentStatus = PlayerStatus.active,
    this.suspensionEndDate,
    List<DisciplinaryAction>? history,
  })  : id = ObjectId(),
        history = history ?? [];

  Map<String, dynamic> toMap() => {
        '_id': id,
        'playerId': playerId,
        'currentStatus': currentStatus.toString(),
        'suspensionEndDate': suspensionEndDate,
        'history': history.map((h) => h.toMap()).toList(),
      };

  factory PlayerDiscipline.fromMap(Map<String, dynamic> map) {
    return PlayerDiscipline(
      playerId: map['playerId'] as String,
      currentStatus: PlayerStatus.values.firstWhere((e) => e.toString() == map['currentStatus'],
          orElse: () => PlayerStatus.active),
      suspensionEndDate: map['suspensionEndDate'] as DateTime?,
      history: (map['history'] as List?)
          ?.map((item) => DisciplinaryAction.fromMap(item as Map<String, dynamic>))
          .toList(),
    )..id.id = map['_id'] as ObjectId;
  }
}
