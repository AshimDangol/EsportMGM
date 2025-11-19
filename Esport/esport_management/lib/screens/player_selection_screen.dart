import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';

class PlayerSelectionScreen extends StatefulWidget {
  final User user;
  const PlayerSelectionScreen({super.key, required this.user});

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  final PlayerService _playerService = PlayerService();
  List<Player> _selectedPlayers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Players'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              Navigator.of(context).pop(_selectedPlayers);
            },
          ),
        ],
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
              final isSelected = _selectedPlayers.any((p) => p.id == player.id);
              return CheckboxListTile(
                title: Text(player.gamerTag),
                subtitle: Text(player.realName ?? ''),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedPlayers.add(player);
                    } else {
                      _selectedPlayers.removeWhere((p) => p.id == player.id);
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
