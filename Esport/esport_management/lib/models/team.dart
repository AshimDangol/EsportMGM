import 'package:mongo_dart/mongo_dart.dart';

enum CompetitiveTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  master,
  grandmaster,
}

enum Region {
  northAmerica,
  europe,
  asia,
  southAmerica,
  oceania,
  global,
}

class Team {
  final ObjectId id;
  final String name;
  final List<String> players;
  final String tournamentId;
  final int eloRating;
  final int seasonalPoints;
  final CompetitiveTier tier;
  final Region region;

  Team({
    required this.name,
    required this.players,
    required this.tournamentId,
    this.eloRating = 1200,
    this.seasonalPoints = 0,
    this.tier = CompetitiveTier.bronze,
    this.region = Region.global,
  }) : id = ObjectId();

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'players': players,
      'tournamentId': tournamentId,
      'elo_rating': eloRating,
      'seasonal_points': seasonalPoints,
      'tier': tier.toString(),
      'region': region.toString(),
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      name: map['name'] as String,
      players: List<String>.from(map['players'] as List),
      tournamentId: map['tournamentId'] as String,
      eloRating: (map['elo_rating'] as num?)?.toInt() ?? 1200,
      seasonalPoints: (map['seasonal_points'] as num?)?.toInt() ?? 0,
      tier: CompetitiveTier.values.firstWhere(
        (e) => e.toString() == map['tier'],
        orElse: () => CompetitiveTier.bronze,
      ),
      region: Region.values.firstWhere(
        (e) => e.toString() == map['region'],
        orElse: () => Region.global,
      ),
    )..id.id = map['_id'] as ObjectId;
  }

  Team copyWith({
    String? name,
    List<String>? players,
    String? tournamentId,
    int? eloRating,
    int? seasonalPoints,
    CompetitiveTier? tier,
    Region? region,
  }) {
    return Team(
      name: name ?? this.name,
      players: players ?? this.players,
      tournamentId: tournamentId ?? this.tournamentId,
      eloRating: eloRating ?? this.eloRating,
      seasonalPoints: seasonalPoints ?? this.seasonalPoints,
      tier: tier ?? this.tier,
      region: region ?? this.region,
    )..id.id = id;
  }
}
