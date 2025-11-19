import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/player_stats.dart';
import 'package:esport_mgm/services/player_stats_service.dart';
import 'package:flutter/material.dart';

class PlayerStatsScreen extends StatefulWidget {
  final Player player;

  const PlayerStatsScreen({super.key, required this.player});

  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> {
  final PlayerStatsService _statsService = PlayerStatsService();
  late Future<PlayerStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _statsService.getPlayerStats(widget.player.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.player.gamerTag} - Stats'),
      ),
      body: FutureBuilder<PlayerStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No stats found for this player.'));
          }

          final stats = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatCard('K/D/A', stats.kda.toStringAsFixed(2)),
                _buildStatCard('Win Rate', '${stats.winRate.toStringAsFixed(1)}%'),
                const Divider(height: 32),
                _buildRawStats(stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRawStats(PlayerStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detailed Statistics', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ListTile(title: const Text('Total Kills'), trailing: Text(stats.kills.toString())),
        ListTile(title: const Text('Total Deaths'), trailing: Text(stats.deaths.toString())),
        ListTile(title: const Text('Total Assists'), trailing: Text(stats.assists.toString())),
        ListTile(title: const Text('Matches Played'), trailing: Text(stats.matchesPlayed.toString())),
        ListTile(title: const Text('Matches Won'), trailing: Text(stats.matchesWon.toString())),
      ],
    );
  }
}
