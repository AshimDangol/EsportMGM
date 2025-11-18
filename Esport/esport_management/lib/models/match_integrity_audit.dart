import 'package:mongo_dart/mongo_dart.dart';

enum ReviewAction {
  noActionTaken,
  warningIssued,
  playerSuspended,
  playerBanned,
  matchOverturned,
}

class MatchIntegrityAudit {
  final ObjectId id;
  final String matchId;
  final String reviewerId; // Admin user ID
  final DateTime timestamp;
  final String notes;
  final ReviewAction actionTaken;

  MatchIntegrityAudit({
    required this.matchId,
    required this.reviewerId,
    required this.notes,
    required this.actionTaken,
  })  : id = ObjectId(),
        timestamp = DateTime.now();

  Map<String, dynamic> toMap() => {
        '_id': id,
        'matchId': matchId,
        'reviewerId': reviewerId,
        'timestamp': timestamp,
        'notes': notes,
        'actionTaken': actionTaken.toString(),
      };

  factory MatchIntegrityAudit.fromMap(Map<String, dynamic> map) {
    return MatchIntegrityAudit(
      matchId: map['matchId'] as String,
      reviewerId: map['reviewerId'] as String,
      notes: map['notes'] as String,
      actionTaken: ReviewAction.values
          .firstWhere((e) => e.toString() == map['actionTaken'], orElse: () => ReviewAction.noActionTaken),
    )
      ..id.id = map['_id'] as ObjectId
      ..timestamp.toUtc(); // Simplified timestamp handling
  }
}
