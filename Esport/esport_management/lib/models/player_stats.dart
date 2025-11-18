import 'package:mongo_dart/mongo_dart.dart';

class PlayerStats {
  final String playerId;
  final int totalKills;
  final int totalDeaths;
  final int totalMatchesPlayed;
  final double kdRatio;
  final double headshotPercentage;

  PlayerStats({
    required this.playerId,
    this.totalKills = 0,
    this.totalDeaths = 0,
    this.totalMatchesPlayed = 0,
    this.headshotPercentage = 0.0,
  }) : kdRatio = (totalDeaths == 0) ? totalKills.toDouble() : totalKills / totalDeaths;

  // This is a factory for generating stats from a list of events.
  // In a real, high-performance system, this would be done on a server, possibly with caching.
  factory PlayerStats.fromEvents(String playerId, List<dynamic> events) {
    int kills = 0;
    int deaths = 0;
    int headshots = 0;

    // This is a highly simplified calculation.
    // A real implementation would need to differentiate event types.
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
