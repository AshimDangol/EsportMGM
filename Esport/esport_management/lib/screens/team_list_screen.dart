import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/screens/player_dashboard_screen.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:flutter/material.dart';

class TeamListScreen extends StatefulWidget {
  const TeamListScreen({super.key});

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  late final TeamService _teamService;
  Future<List<Team>>? _teamsFuture;

  @override
  void initState() {
    super.initState();
    _teamService = TeamService();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      // For simplicity, we load all teams. In a real app, this might be teams for the current user.
      _teamsFuture = _teamService.getAllTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Teams'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTeams,
        child: FutureBuilder<List<Team>>(
          future: _teamsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final teams = snapshot.data ?? [];
            if (teams.isEmpty) {
              return const Center(child: Text('No teams found.'));
            }

            return ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return ExpansionTile(
                  title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: team.players.map((playerId) {
                    return ListTile(
                      title: Text(playerId),
                      trailing: IconButton(
                        icon: const Icon(Icons.dashboard),
                        tooltip: 'View Player Dashboard',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerDashboardScreen(playerId: playerId),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
