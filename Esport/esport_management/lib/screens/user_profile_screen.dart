import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/edit_player_screen.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;
  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final PlayerService _playerService = PlayerService();
  Future<Player?>? _playerFuture;

  @override
  void initState() {
    super.initState();
    _playerFuture = _playerService.getPlayerByUserId(widget.user.id);
  }

  void _refresh() {
    setState(() {
      _playerFuture = _playerService.getPlayerByUserId(widget.user.id);
    });
  }

  void _navigateToPlayerScreen(Player? player) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPlayerScreen(user: widget.user, player: player),
      ),
    );
    _refresh(); // Refresh the profile screen after edits
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: FutureBuilder<Player?>(
          future: _playerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final player = snapshot.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('User ID: ${widget.user.id}'),
                Text('Email: ${widget.user.email}'),
                if (player != null)
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: ListTile(
                      title: Text(player.gamerTag),
                      subtitle: Text(player.realName ?? 'N/A'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToPlayerScreen(player),
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _navigateToPlayerScreen(null),
                    child: const Text('Create Player Profile'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
