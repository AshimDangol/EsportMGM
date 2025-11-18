import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/edit_player_screen.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';

class PlayerListScreen extends StatefulWidget {
  final User user;
  const PlayerListScreen({super.key, required this.user});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  final PlayerService _playerService = PlayerService();

  void _navigateToEditScreen([Player? player]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlayerScreen(user: widget.user, player: player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
      ),
      body: StreamBuilder<List<Player>>(
        stream: _playerService.getPlayersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No players found.'));
          }

          final players = snapshot.data!;
          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return ListTile(
                title: Text(player.gamerTag),
                subtitle: Text(player.realName ?? 'No real name'),
                onTap: () => _navigateToEditScreen(player),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
