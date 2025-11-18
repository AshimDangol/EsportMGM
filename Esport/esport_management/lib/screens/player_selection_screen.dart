import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';

class PlayerSelectionScreen extends StatefulWidget {
  final List<String> existingPlayerIds;
  const PlayerSelectionScreen({super.key, required this.existingPlayerIds});

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  final PlayerService _playerService = PlayerService();
  late Future<List<Player>> _playersFuture;

  @override
  void initState() {
    super.initState();
    _playersFuture = _playerService.getPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Player'),
      ),
      body: FutureBuilder<List<Player>>(
        future: _playersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No players found.'));
          }

          // Filter out players who are already in the team
          final availablePlayers = snapshot.data!
              .where((p) => !widget.existingPlayerIds.contains(p.id))
              .toList();

          if (availablePlayers.isEmpty) {
            return const Center(child: Text('All players are already on this team.'));
          }

          return ListView.builder(
            itemCount: availablePlayers.length,
            itemBuilder: (context, index) {
              final player = availablePlayers[index];
              return ListTile(
                title: Text(player.gamerTag),
                onTap: () {
                  // Return the selected player to the previous screen
                  Navigator.of(context).pop(player);
                },
              );
            },
          );
        },
      ),
    );
  }
}
