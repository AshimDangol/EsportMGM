import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum Region {
  global,
  northAmerica,
  europe,
  asia,
}

@immutable
class Team {
  final String id;
  final String name;
  final String game;
  final Region region;
  final int eloRating;
  final List<String> players;
  final String managerId;
  final String clanId;

  const Team({
    required this.id,
    required this.name,
    required this.game,
    required this.region,
    this.eloRating = 1200,
    this.players = const [],
    required this.managerId,
    required this.clanId,
  });

  factory Team.fromMap(Map<String, dynamic> data, String documentId) {
    return Team(
      id: documentId,
      name: data['name'] ?? '',
      game: data['game'] ?? '',
      region: Region.values.firstWhere((e) => e.name == data['region'], orElse: () => Region.global),
      eloRating: data['elo_rating'] ?? 1200,
      players: List<String>.from(data['players'] ?? []),
      managerId: data['managerId'] ?? '',
      clanId: data['clanId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'game': game,
      'region': region.name,
      'elo_rating': eloRating,
      'players': players,
      'managerId': managerId,
      'clanId': clanId,
    };
  }

  Team copyWith({
    String? id,
    String? name,
    String? game,
    Region? region,
    int? eloRating,
    List<String>? players,
    String? managerId,
    String? clanId,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      game: game ?? this.game,
      region: region ?? this.region,
      eloRating: eloRating ?? this.eloRating,
      players: players ?? this.players,
      managerId: managerId ?? this.managerId,
      clanId: clanId ?? this.clanId,
    );
  }

  @override
  String toString() {
    return 'Team(id: $id, name: $name, game: $game, region: $region, eloRating: $eloRating, players: $players, managerId: $managerId, clanId: $clanId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Team &&
      other.id == id &&
      other.name == name &&
      other.game == game &&
      other.region == region &&
      other.eloRating == eloRating &&
      listEquals(other.players, players) &&
      other.managerId == managerId &&
      other.clanId == clanId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      game.hashCode ^
      region.hashCode ^
      eloRating.hashCode ^
      players.hashCode ^
      managerId.hashCode ^
      clanId.hashCode;
  }
}
