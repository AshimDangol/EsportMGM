import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/player_stats.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _eventsCollection;

  AnalyticsService() {
    _eventsCollection = _firestore.collection('game_events');
  }

  Future<PlayerStats> getStatsForPlayer(String playerId) async {
    final eventsSnapshot = await _eventsCollection.where('playerId', isEqualTo: playerId).get();
    final events = eventsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    int kills = 0;
    int deaths = 0;
    int headshots = 0;

    for (final event in events) {
      if (event['eventType'] == 'GameEventType.kill') {
        if (event['playerId'] == playerId) {
          kills++;
          if (event['eventData']?['headshot'] == true) {
            headshots++;
          }
        } else if (event['eventData']?['victimId'] == playerId) {
          deaths++;
        }
      }
    }

    final uniqueMatchIds = events.map((e) => e['matchId']).toSet().length;

    return PlayerStats(
      playerId: playerId,
      totalKills: kills,
      totalDeaths: deaths,
      totalMatchesPlayed: uniqueMatchIds,
      headshotPercentage: (kills == 0) ? 0.0 : (headshots / kills) * 100,
    );
  }
}
