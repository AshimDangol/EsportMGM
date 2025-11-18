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

  factory PlayerStats.fromMap(Map<String, dynamic> data, String playerId) {
    return PlayerStats(
      playerId: playerId,
      totalKills: data['totalKills'] ?? 0,
      totalDeaths: data['totalDeaths'] ?? 0,
      totalMatchesPlayed: data['totalMatchesPlayed'] ?? 0,
      headshotPercentage: (data['headshotPercentage'] ?? 0.0).toDouble(),
    );
  }
}
