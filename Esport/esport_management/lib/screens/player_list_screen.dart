import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/edit_player_screen.dart';
import 'package:esport_mgm/screens/player_details_screen.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerListScreen extends StatefulWidget {
  final User user;
  const PlayerListScreen({super.key, required this.user});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  final _searchController = TextEditingController();
  Future<List<Player>>? _playersFuture;

  @override
  void initState() {
    super.initState();
    _playersFuture = context.read<PlayerService>().getPlayers();
  }

  void _searchPlayers(String query) {
    setState(() {
      if (query.isEmpty) {
        _playersFuture = context.read<PlayerService>().getPlayers();
      } else {
        _playersFuture = context.read<PlayerService>().searchPlayers(query);
      }
    });
  }

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

  void _navigateToDetails(Player player) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlayerDetailsScreen(player: player, user: widget.user),
      ),
    );
  }

  void _navigateToCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPlayerScreen(user: widget.user),
      ),
    );
    _searchPlayers(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by GamerTag or ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchPlayers,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Player>>(
              future: _playersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final players = snapshot.data ?? [];
                if (players.isEmpty) {
                  return const Center(child: Text('No players found.'));
                }

                return ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(player.status),
                          radius: 8,
                        ),
                        title: Text(player.gamerTag),
                        subtitle: Text(player.realName ?? 'No real name'),
                        onTap: () => _navigateToDetails(player),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        tooltip: 'Add Player',
        child: const Icon(Icons.add),
      ),
    );
  }
}
