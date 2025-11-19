import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/match.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

enum TournamentFormat {
  singleElimination,
  doubleElimination,
  roundRobin,
  swiss,
  league,
}

@immutable
class PrizeDistribution {
  final int rank;
  final double percentage;
  final double fixedAmount;

  const PrizeDistribution({
    required this.rank,
    this.percentage = 0.0,
    this.fixedAmount = 0.0,
  });

  Map<String, dynamic> toMap() => {
        'rank': rank,
        'percentage': percentage,
        'fixedAmount': fixedAmount,
      };

  factory PrizeDistribution.fromMap(Map<String, dynamic> map) {
    return PrizeDistribution(
      rank: map['rank'] as int,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      fixedAmount: (map['fixedAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

@immutable
class Tournament {
  final String id;
  final String name;
  final String game;
  final DateTime startDate;
  final DateTime? endDate;
  final String? venue;
  final String description;
  final double prizePool;
  final List<PrizeDistribution> prizeDistribution;
  final List<String> registeredClanIds;
  final List<String> checkedInClanIds;
  final List<String> participatingPlayerIds;
  final TournamentFormat format;
  final String rules;
  final List<Match> matches;
  final Map<String, int> seeding;
  final String adminId;
  final String joinCode;

  const Tournament({
    this.id = '',
    required this.name,
    required this.game,
    required this.startDate,
    this.endDate,
    this.venue,
    this.description = '',
    this.prizePool = 0.0,
    this.prizeDistribution = const [],
    this.registeredClanIds = const [],
    this.checkedInClanIds = const [],
    this.participatingPlayerIds = const [],
    this.format = TournamentFormat.singleElimination,
    this.rules = '',
    this.matches = const [],
    this.seeding = const {},
    required this.adminId,
    required this.joinCode,
  });

  factory Tournament.fromMap(Map<String, dynamic> map, String documentId) {
    return Tournament(
      id: documentId,
      name: map['name'] as String? ?? '',
      game: map['game'] as String? ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      venue: map['venue'] as String?,
      description: map['description'] as String? ?? '',
      prizePool: (map['prizePool'] as num? ?? 0.0).toDouble(),
      prizeDistribution: (map['prizeDistribution'] as List? ?? [])
          .map((p) => PrizeDistribution.fromMap(p as Map<String, dynamic>))
          .toList(),
      registeredClanIds: List<String>.from(map['registeredClanIds'] ?? []),
      checkedInClanIds: List<String>.from(map['checkedInClanIds'] ?? []),
      participatingPlayerIds: List<String>.from(map['participatingPlayerIds'] ?? []),
      format: TournamentFormat.values.firstWhere(
        (e) => e.name == map['format'],
        orElse: () => TournamentFormat.singleElimination,
      ),
      rules: map['rules'] as String? ?? '',
      matches: (map['matches'] as List? ?? []).map((m) => Match.fromMap(m)).toList(),
      seeding: Map<String, int>.from(map['seeding'] ?? {}),
      adminId: map['adminId'] as String? ?? '',
      joinCode: map['joinCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'game': game,
      'startDate': startDate,
      'endDate': endDate,
      'venue': venue,
      'description': description,
      'prizePool': prizePool,
      'prizeDistribution': prizeDistribution.map((p) => p.toMap()).toList(),
      'registeredClanIds': registeredClanIds,
      'checkedInClanIds': checkedInClanIds,
      'participatingPlayerIds': participatingPlayerIds,
      'format': format.name,
      'rules': rules,
      'matches': matches.map((m) => m.toMap()).toList(),
      'seeding': seeding,
      'adminId': adminId,
      'joinCode': joinCode,
    };
  }

  Tournament copyWith({
    String? id,
    String? name,
    String? game,
    DateTime? startDate,
    DateTime? endDate,
    String? venue,
    String? description,
    double? prizePool,
    List<PrizeDistribution>? prizeDistribution,
    List<String>? registeredClanIds,
    List<String>? checkedInClanIds,
    List<String>? participatingPlayerIds,
    TournamentFormat? format,
    String? rules,
    List<Match>? matches,
    Map<String, int>? seeding,
    String? adminId,
    String? joinCode,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      game: game ?? this.game,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      venue: venue ?? this.venue,
      description: description ?? this.description,
      prizePool: prizePool ?? this.prizePool,
      prizeDistribution: prizeDistribution ?? this.prizeDistribution,
      registeredClanIds: registeredClanIds ?? this.registeredClanIds,
      checkedInClanIds: checkedInClanIds ?? this.checkedInClanIds,
      participatingPlayerIds: participatingPlayerIds ?? this.participatingPlayerIds,
      format: format ?? this.format,
      rules: rules ?? this.rules,
      matches: matches ?? this.matches,
      seeding: seeding ?? this.seeding,
      adminId: adminId ?? this.adminId,
      joinCode: joinCode ?? this.joinCode,
    );
  }

  @override
  String toString() {
    return 'Tournament(id: $id, name: $name, game: $game, startDate: $startDate, endDate: $endDate, venue: $venue, description: $description, prizePool: $prizePool, prizeDistribution: $prizeDistribution, registeredClanIds: $registeredClanIds, checkedInClanIds: $checkedInClanIds, participatingPlayerIds: $participatingPlayerIds, format: $format, rules: $rules, matches: $matches, seeding: $seeding, adminId: $adminId, joinCode: $joinCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is Tournament &&
        other.id == id &&
        other.name == name &&
        other.game == game &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.venue == venue &&
        other.description == description &&
        other.prizePool == prizePool &&
        listEquals(other.prizeDistribution, prizeDistribution) &&
        listEquals(other.registeredClanIds, registeredClanIds) &&
        listEquals(other.checkedInClanIds, checkedInClanIds) &&
        listEquals(other.participatingPlayerIds, participatingPlayerIds) &&
        other.format == format &&
        other.rules == rules &&
        listEquals(other.matches, matches) &&
        mapEquals(other.seeding, seeding) &&
        other.adminId == adminId &&
        other.joinCode == joinCode;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        game.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        venue.hashCode ^
        description.hashCode ^
        prizePool.hashCode ^
        prizeDistribution.hashCode ^
        registeredClanIds.hashCode ^
        checkedInClanIds.hashCode ^
        participatingPlayerIds.hashCode ^
        format.hashCode ^
        rules.hashCode ^
        matches.hashCode ^
        seeding.hashCode ^
        adminId.hashCode ^
        joinCode.hashCode;
  }
}
