import 'package:esport_mgm/models/match.dart';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

enum TournamentFormat {
  singleElimination,
  doubleElimination,
  roundRobin,
  swiss,
  league,
}

// Represents a single entry in the prize distribution list
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
  final ObjectId id;
  final String name;
  final String game;
  final DateTime startDate;
  final DateTime? endDate;
  final String? venue;
  final String description;
  final double prizePool;
  final List<PrizeDistribution> prizeDistribution;
  final List<String> registeredTeamIds;
  final List<String> checkedInTeamIds;
  final TournamentFormat format;
  final String rules;
  final List<Match> matches;
  final Map<String, int> seeding;

  Tournament({
    required this.name,
    required this.game,
    required this.startDate,
    this.endDate,
    this.venue,
    this.description = '',
    this.prizePool = 0.0,
    this.prizeDistribution = const [],
    this.registeredTeamIds = const [],
    this.checkedInTeamIds = const [],
    this.format = TournamentFormat.singleElimination,
    this.rules = '',
    this.matches = const [],
    this.seeding = const {},
  }) : id = ObjectId();

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      name: map['name'] as String? ?? '',
      game: map['game'] as String? ?? '',
      startDate: map['startDate'] as DateTime,
      endDate: map['endDate'] as DateTime?,
      venue: map['venue'] as String?,
      description: map['description'] as String? ?? '',
      prizePool: (map['prizePool'] as num? ?? 0.0).toDouble(),
      prizeDistribution: (map['prizeDistribution'] as List? ?? [])
          .map((p) => PrizeDistribution.fromMap(p as Map<String, dynamic>))
          .toList(),
      registeredTeamIds: List<String>.from(map['registeredTeamIds'] ?? []),
      checkedInTeamIds: List<String>.from(map['checkedInTeamIds'] ?? []),
      format: TournamentFormat.values.firstWhere(
        (e) => e.toString() == map['format'],
        orElse: () => TournamentFormat.singleElimination,
      ),
      rules: map['rules'] as String? ?? '',
      matches: (map['matches'] as List? ?? []).map((m) => Match.fromMap(m)).toList(),
      seeding: Map<String, int>.from(map['seeding'] ?? {}),
    )..id.id = map['_id'] as ObjectId;
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'game': game,
      'startDate': startDate,
      'endDate': endDate,
      'venue': venue,
      'description': description,
      'prizePool': prizePool,
      'prizeDistribution': prizeDistribution.map((p) => p.toMap()).toList(),
      'registeredTeamIds': registeredTeamIds,
      'checkedInTeamIds': checkedInTeamIds,
      'format': format.toString(),
      'rules': rules,
      'matches': matches.map((m) => m.toMap()).toList(),
      'seeding': seeding,
    };
  }

  Tournament copyWith({
    ObjectId? id,
    String? name,
    String? game,
    DateTime? startDate,
    DateTime? endDate,
    String? venue,
    String? description,
    double? prizePool,
    List<PrizeDistribution>? prizeDistribution,
    List<String>? registeredTeamIds,
    List<String>? checkedInTeamIds,
    TournamentFormat? format,
    String? rules,
    List<Match>? matches,
    Map<String, int>? seeding,
  }) {
    return Tournament(
      name: name ?? this.name,
      game: game ?? this.game,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      venue: venue ?? this.venue,
      description: description ?? this.description,
      prizePool: prizePool ?? this.prizePool,
      prizeDistribution: prizeDistribution ?? this.prizeDistribution,
      registeredTeamIds: registeredTeamIds ?? this.registeredTeamIds,
      checkedInTeamIds: checkedInTeamIds ?? this.checkedInTeamIds,
      format: format ?? this.format,
      rules: rules ?? this.rules,
      matches: matches ?? this.matches,
      seeding: seeding ?? this.seeding,
    )..id.id = id ?? this.id;
  }
}
