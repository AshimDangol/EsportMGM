import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class PlayerStats {
  final String id;          // Corresponds to the Player ID
  final int kills;
  final int deaths;
  final int assists;
  final int matchesPlayed;
  final int matchesWon;

  const PlayerStats({
    required this.id,
    this.kills = 0,
    this.deaths = 0,
    this.assists = 0,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
  });

  // Helper for a clean initial state
  factory PlayerStats.initial(String id) {
    return PlayerStats(id: id);
  }

  // Calculated property for Kill/Death/Assist Ratio
  double get kda {
    if (deaths == 0) {
      // Avoid division by zero; can be considered infinite KDA
      return (kills + assists).toDouble();
    }
    return (kills + assists) / deaths;
  }

  // Calculated property for Win Rate
  double get winRate {
    if (matchesPlayed == 0) {
      return 0.0;
    }
    return (matchesWon / matchesPlayed) * 100;
  }

  factory PlayerStats.fromMap(String id, Map<String, dynamic> data) {
    return PlayerStats(
      id: id,
      kills: data['kills'] as int? ?? 0,
      deaths: data['deaths'] as int? ?? 0,
      assists: data['assists'] as int? ?? 0,
      matchesPlayed: data['matchesPlayed'] as int? ?? 0,
      matchesWon: data['matchesWon'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kills': kills,
      'deaths': deaths,
      'assists': assists,
      'matchesPlayed': matchesPlayed,
      'matchesWon': matchesWon,
    };
  }
}
