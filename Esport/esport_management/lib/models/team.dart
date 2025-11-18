import 'package:cloud_firestore/cloud_firestore.dart';

enum Region {
  global,
  northAmerica,
  europe,
  asia,
}

class Team {
  final String id;
  final String name;
  final Region region;
  final int eloRating;
  final List<String> players;

  Team({
    required this.id,
    required this.name,
    required this.region,
    required this.eloRating,
    required this.players,
  });

  factory Team.fromMap(Map<String, dynamic> data, String documentId) {
    return Team(
      id: documentId,
      name: data['name'] ?? '',
      region: Region.values.firstWhere((e) => e.toString() == data['region'], orElse: () => Region.global),
      eloRating: data['elo_rating'] ?? 1200,
      players: List<String>.from(data['players'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'region': region.toString(),
      'elo_rating': eloRating,
      'players': players,
    };
  }
}
