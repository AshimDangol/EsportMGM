import 'package:esport_mgm/models/player_stats.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AnalyticsService {
  final Db _db;

  AnalyticsService(this._db);

  DbCollection get eventCollection => _db.collection('game_events');

  // In a real app, you would add more filters (e.g., by tournament, season, etc.)
  Future<PlayerStats> getStatsForPlayer(String playerId) async {
    final events = await eventCollection.find(where.eq('playerId', playerId)).toList();
    // In a real-world scenario, you'd likely need events where the player is the *victim* too.
    // This is a simplification.

    return PlayerStats.fromEvents(playerId, events);
  }
}
