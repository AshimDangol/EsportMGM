import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/player_stats.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/edit_player_screen.dart';
import 'package:esport_mgm/services/player_stats_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerDetailsScreen extends StatefulWidget {
  final Player player;
  final User user;

  const PlayerDetailsScreen({super.key, required this.player, required this.user});

  @override
  State<PlayerDetailsScreen> createState() => _PlayerDetailsScreenState();
}

class _PlayerDetailsScreenState extends State<PlayerDetailsScreen> {
  late Future<PlayerStats> _playerStatsFuture;

  @override
  void initState() {
    super.initState();
    _playerStatsFuture = context.read<PlayerStatsService>().getPlayerStats(widget.player.id);
  }

  bool get _isAdmin => widget.user.role == UserRole.admin;

  Color _getStatusColor(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.active:
        return Colors.green;
      case PlayerStatus.inactive:
        return Colors.orange;
      case PlayerStatus.banned:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player.gamerTag),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditPlayerScreen(user: widget.user, player: widget.player),
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Gamer Tag'),
              subtitle: Text(widget.player.gamerTag, style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              title: const Text('Real Name'),
              subtitle: Text(widget.player.realName ?? 'N/A', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              title: const Text('Nationality'),
              subtitle: Text(widget.player.nationality ?? 'N/A', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              title: const Text('Status'),
              subtitle: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.player.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.player.status.name, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Text('Player Stats', style: Theme.of(context).textTheme.headlineSmall),
            _buildStatsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return FutureBuilder<PlayerStats>(
      future: _playerStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Could not fetch stats.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No stats available.'));
        }

        final stats = snapshot.data!;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Kills', stats.kills.toString()),
                    _buildStat('Deaths', stats.deaths.toString()),
                    _buildStat('Assists', stats.assists.toString()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('K/D/A', stats.kda.toStringAsFixed(2)),
                    _buildStat('Win Rate', '${stats.winRate.toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String title, String value) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}
