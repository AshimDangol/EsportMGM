import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum MatchStatus {
  pending,
  inProgress,
  completed,
  archived,
}

@immutable
class Match {
  final String id;
  final int roundNumber;
  final int matchNumber;
  final String? clan1Id;
  final String? clan2Id;
  final int clan1Score;
  final int clan2Score;
  final String? winnerId;
  final MatchStatus status;
  final DateTime? scheduledTime;

  const Match({
    this.id = '',
    required this.roundNumber,
    required this.matchNumber,
    this.clan1Id,
    this.clan2Id,
    this.clan1Score = 0,
    this.clan2Score = 0,
    this.winnerId,
    this.status = MatchStatus.pending,
    this.scheduledTime,
  });

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'] as String? ?? const Uuid().v4(),
      roundNumber: map['roundNumber'] as int? ?? 0,
      matchNumber: map['matchNumber'] as int? ?? 0,
      clan1Id: map['clan1Id'] as String?,
      clan2Id: map['clan2Id'] as String?,
      clan1Score: map['clan1Score'] as int? ?? 0,
      clan2Score: map['clan2Score'] as int? ?? 0,
      winnerId: map['winnerId'] as String?,
      status: MatchStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MatchStatus.pending,
      ),
      scheduledTime: (map['scheduledTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roundNumber': roundNumber,
      'matchNumber': matchNumber,
      'clan1Id': clan1Id,
      'clan2Id': clan2Id,
      'clan1Score': clan1Score,
      'clan2Score': clan2Score,
      'winnerId': winnerId,
      'status': status.name,
      'scheduledTime': scheduledTime != null ? Timestamp.fromDate(scheduledTime!) : null,
    };
  }

  Match copyWith({
    String? id,
    int? roundNumber,
    int? matchNumber,
    String? clan1Id,
    String? clan2Id,
    int? clan1Score,
    int? clan2Score,
    String? winnerId,
    MatchStatus? status,
    DateTime? scheduledTime,
  }) {
    return Match(
      id: id ?? this.id,
      roundNumber: roundNumber ?? this.roundNumber,
      matchNumber: matchNumber ?? this.matchNumber,
      clan1Id: clan1Id ?? this.clan1Id,
      clan2Id: clan2Id ?? this.clan2Id,
      clan1Score: clan1Score ?? this.clan1Score,
      clan2Score: clan2Score ?? this.clan2Score,
      winnerId: winnerId ?? this.winnerId,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }

  @override
  String toString() {
    return 'Match(id: $id, roundNumber: $roundNumber, matchNumber: $matchNumber, clan1Id: $clan1Id, clan2Id: $clan2Id, clan1Score: $clan1Score, clan2Score: $clan2Score, winnerId: $winnerId, status: $status, scheduledTime: $scheduledTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Match &&
        other.id == id &&
        other.roundNumber == roundNumber &&
        other.matchNumber == matchNumber &&
        other.clan1Id == clan1Id &&
        other.clan2Id == clan2Id &&
        other.clan1Score == clan1Score &&
        other.clan2Score == clan2Score &&
        other.winnerId == winnerId &&
        other.status == status &&
        other.scheduledTime == scheduledTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roundNumber.hashCode ^
        matchNumber.hashCode ^
        clan1Id.hashCode ^
        clan2Id.hashCode ^
        clan1Score.hashCode ^
        clan2Score.hashCode ^
        winnerId.hashCode ^
        status.hashCode ^
        scheduledTime.hashCode;
  }
}
