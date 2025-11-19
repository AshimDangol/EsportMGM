import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/edit_player_screen.dart';
import 'package:esport_mgm/screens/player_stats_screen.dart';
import 'package:flutter/material.dart';

class PlayerDetailsScreen extends StatelessWidget {
  final Player player;
  final User user;

  const PlayerDetailsScreen({super.key, required this.player, required this.user});

  bool get _isAdmin => user.role == UserRole.admin;

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
        title: Text(player.gamerTag),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditPlayerScreen(user: user, player: player),
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
              subtitle: Text(player.gamerTag, style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              title: const Text('Real Name'),
              subtitle: Text(player.realName ?? 'N/A', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              title: const Text('Nationality'),
              subtitle: Text(player.nationality ?? 'N/A', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              title: const Text('Status'),
              subtitle: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(player.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(player.status.name, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text('View Player Stats'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlayerStatsScreen(player: player),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
