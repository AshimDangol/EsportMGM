import 'package:mongo_dart/mongo_dart.dart';

enum MatchStatus {
  scheduled,
  inProgress,
  completed,
  pending, // Not yet scheduled
}

class Match {
  final ObjectId id;
  final int roundNumber;
  final int matchNumber;

  final String? team1Id;
  final String? team2Id;

  final int team1Score;
  final int team2Score;

  final String? winnerId;
  final DateTime? scheduledTime;
  final MatchStatus status;

  Match({
    ObjectId? id,
    required this.roundNumber,
    required this.matchNumber,
    this.team1Id,
    this.team2Id,
    this.team1Score = 0,
    this.team2Score = 0,
    this.winnerId,
    this.scheduledTime,
    this.status = MatchStatus.pending,
  }) : id = id ?? ObjectId();

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['_id'] as ObjectId?,
      roundNumber: map['roundNumber'] as int,
      matchNumber: map['matchNumber'] as int,
      team1Id: map['team1Id'] as String?,
      team2Id: map['team2Id'] as String?,
      team1Score: map['team1Score'] as int? ?? 0,
      team2Score: map['team2Score'] as int? ?? 0,
      winnerId: map['winnerId'] as String?,
      scheduledTime: map['scheduledTime'] as DateTime?,
      status: MatchStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => MatchStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'roundNumber': roundNumber,
      'matchNumber': matchNumber,
      'team1Id': team1Id,
      'team2Id': team2Id,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'winnerId': winnerId,
      'scheduledTime': scheduledTime,
      'status': status.toString(),
    };
  }

  Match copyWith({
    ObjectId? id,
    int? roundNumber,
    int? matchNumber,
    String? team1Id,
    String? team2Id,
    int? team1Score,
    int? team2Score,
    String? winnerId,
    DateTime? scheduledTime,
    MatchStatus? status,
  }) {
    return Match(
      id: id ?? this.id,
      roundNumber: roundNumber ?? this.roundNumber,
      matchNumber: matchNumber ?? this.matchNumber,
      team1Id: team1Id ?? this.team1Id,
      team2Id: team2Id ?? this.team2Id,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      winnerId: winnerId ?? this.winnerId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
    );
  }
}
