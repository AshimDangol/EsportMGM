import 'package:esport_mgm/models/match.dart';
import 'package:esport_mgm/models/team.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:math';

class RankingService {
  static const String _teamCollection = 'teams';
  final Db _db;

  RankingService(this._db);

  DbCollection get teamCollection => _db.collection(_teamCollection);

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

    final team1Doc = await teamCollection.findOne(where.id(ObjectId.parse(match.team1Id!)));
    final team2Doc = await teamCollection.findOne(where.id(ObjectId.parse(match.team2Id!)));

    if (team1Doc == null || team2Doc == null) return;

    final team1 = Team.fromMap(team1Doc);
    final team2 = Team.fromMap(team2Doc);

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

    final actualScore1 = winnerId == team1.id.toHexString() ? 1.0 : 0.0;
    final actualScore2 = winnerId == team2.id.toHexString() ? 1.0 : 0.0;

    final newElo1 = elo1 + kFactor * (actualScore1 - expectedScore1);
    final newElo2 = elo2 + kFactor * (actualScore2 - expectedScore2);

    await teamCollection.updateOne(where.id(team1.id), modify.set('elo_rating', newElo1.round()));
    await teamCollection.updateOne(where.id(team2.id), modify.set('elo_rating', newElo2.round()));
  }

  Future<void> _updateSeasonalPoints(String winnerId) async {
    final winnerDoc = await teamCollection.findOne(where.id(ObjectId.parse(winnerId)));
    if (winnerDoc == null) return;

    final currentPoints = (winnerDoc['seasonal_points'] as num?)?.toInt() ?? 0;
    final newPoints = currentPoints + _pointsPerWin;

    final newTier = _getTierForPoints(newPoints);

    await teamCollection.updateOne(
      where.id(ObjectId.parse(winnerId)),
      modify
          .set('seasonal_points', newPoints)
          .set('tier', newTier.toString()),
    );
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
