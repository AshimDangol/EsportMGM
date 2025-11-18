import 'package:esport_mgm/models/player_stats.dart';
import 'package:esport_mgm/services/analytics_service.dart';
import 'package:flutter/material.dart';

class PlayerDashboardScreen extends StatefulWidget {
  final String playerId;

  const PlayerDashboardScreen({super.key, required this.playerId});

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> {
  late final AnalyticsService _analyticsService;
  Future<PlayerStats>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsService = AnalyticsService();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _statsFuture = _analyticsService.getStatsForPlayer(widget.playerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard: ${widget.playerId}'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: FutureBuilder<PlayerStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading stats: ${snapshot.error}'));
            }
            final stats = snapshot.data;
            if (stats == null) {
              return const Center(child: Text('No stats available for this player.'));
            }

            return GridView.count(
              crossAxisCount: 2, // 2 columns
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildStatCard('Total Kills', stats.totalKills.toString()),
                _buildStatCard('Total Deaths', stats.totalDeaths.toString()),
                _buildStatCard('K/D Ratio', stats.kdRatio.toStringAsFixed(2)),
                _buildStatCard('Headshot %', '${stats.headshotPercentage.toStringAsFixed(1)}%'),
                _buildStatCard('Matches Played', stats.totalMatchesPlayed.toString()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
