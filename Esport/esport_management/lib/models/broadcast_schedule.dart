import 'package:mongo_dart/mongo_dart.dart';

class BroadcastScheduleItem {
  final ObjectId id;
  final String tournamentId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;
  final List<String> assignedTalentIds; // IDs of commentators, hosts, etc.

  BroadcastScheduleItem({
    required this.tournamentId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.notes,
    this.assignedTalentIds = const [],
  }) : id = ObjectId();

  Map<String, dynamic> toMap() => {
        '_id': id,
        'tournamentId': tournamentId,
        'title': title,
        'startTime': startTime,
        'endTime': endTime,
        'notes': notes,
        'assignedTalentIds': assignedTalentIds,
      };

  factory BroadcastScheduleItem.fromMap(Map<String, dynamic> map) {
    return BroadcastScheduleItem(
      tournamentId: map['tournamentId'] as String,
      title: map['title'] as String,
      startTime: map['startTime'] as DateTime,
      endTime: map['endTime'] as DateTime,
      notes: map['notes'] as String?,
      assignedTalentIds: List<String>.from(map['assignedTalentIds'] ?? []),
    )..id.id = map['_id'] as ObjectId;
  }
}
