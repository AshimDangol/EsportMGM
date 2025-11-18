import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/competitive_tier.dart';
import 'package:esport_mgm/models/match.dart';
import 'package:esport_mgm/models/team.dart';
import 'dart:math';

class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _teamCollection;

  RankingService() {
    _teamCollection = _firestore.collection('teams');
  }

  static const int _pointsPerWin = 10;
  static const Map<int, CompetitiveTier> _tierThresholds = {
    500: CompetitiveTier.grandmaster,
    400: CompetitiveTier.master,
    300: CompetitiveTier.diamond,
    200: CompetitiveTier.platinum,
    100: CompetitiveTier.gold,
    50: CompetitiveTier.silver,
    0: CompetitiveTier.bronze,
  };

  Future<void> updatePostMatchStats(Match match) async {
    if (match.winnerId == null) return; // No winner, no updates

    final team1Doc = await _teamCollection.doc(match.team1Id!).get();
    final team2Doc = await _teamCollection.doc(match.team2Id!).get();

    if (!team1Doc.exists || !team2Doc.exists) return;

    final team1 = Team.fromMap(team1Doc.data() as Map<String, dynamic>, team1Doc.id);
    final team2 = Team.fromMap(team2Doc.data() as Map<String, dynamic>, team2Doc.id);

    // 1. Update ELO
    await _updateElo(team1, team2, match.winnerId!);

    // 2. Update Seasonal Points
    await _updateSeasonalPoints(match.winnerId!);
  }

  Future<void> _updateElo(Team team1, Team team2, String winnerId) async {
    const int kFactor = 32;
    final elo1 = team1.eloRating.toDouble();
    final elo2 = team2.eloRating.toDouble();

    final expectedScore1 = 1 / (1 + pow(10, (elo2 - elo1) / 400));
    final expectedScore2 = 1 / (1 + pow(10, (elo1 - elo2) / 400));

    final actualScore1 = winnerId == team1.id ? 1.0 : 0.0;
    final actualScore2 = winnerId == team2.id ? 1.0 : 0.0;

    final newElo1 = elo1 + kFactor * (actualScore1 - expectedScore1);
    final newElo2 = elo2 + kFactor * (actualScore2 - expectedScore2);

    await _teamCollection.doc(team1.id).update({'elo_rating': newElo1.round()});
    await _teamCollection.doc(team2.id).update({'elo_rating': newElo2.round()});
  }

  Future<void> _updateSeasonalPoints(String winnerId) async {
    final winnerDoc = await _teamCollection.doc(winnerId).get();
    if (!winnerDoc.exists) return;

    final currentPoints = (winnerDoc.data() as Map<String, dynamic>)['seasonal_points'] ?? 0;
    final newPoints = currentPoints + _pointsPerWin;

    final newTier = _getTierForPoints(newPoints);

    await _teamCollection.doc(winnerId).update({
      'seasonal_points': newPoints,
      'tier': newTier.toString(),
    });
  }

  CompetitiveTier _getTierForPoints(int points) {
    for (final entry in _tierThresholds.entries) {
      if (points >= entry.key) {
        return entry.value;
      }
    }
    return CompetitiveTier.bronze;
  }
}
