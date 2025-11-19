import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/edit_team_screen.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';

class TeamDetailsScreen extends StatefulWidget {
  final Team team;
  final User user;

  const TeamDetailsScreen({super.key, required this.team, required this.user});

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  final PlayerService _playerService = PlayerService();
  late Future<List<Player>> _playersFuture;

  bool get _canEdit {
    return widget.user.role == UserRole.admin || widget.team.managerId == widget.user.id;
  }

  @override
  void initState() {
    super.initState();
    _playersFuture = _playerService.getPlayersByIds(widget.team.playerIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.name),
        actions: [
          if (_canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditTeamScreen(user: widget.user, teamId: widget.team.id),
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
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Team Name: ${widget.team.name}', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Game: ${widget.team.game}', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Region: ${widget.team.region}', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Roster', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<Player>>(
                future: _playersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No players found on this team.'));
                  }
                  final players = snapshot.data!;
                  return ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return ListTile(
                        title: Text(player.gamerTag),
                        subtitle: Text(player.realName ?? 'N/A'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
