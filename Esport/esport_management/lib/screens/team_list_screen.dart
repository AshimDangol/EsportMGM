import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/create_team_screen.dart';
import 'package:esport_mgm/screens/team_details_screen.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:flutter/material.dart';

class TeamListScreen extends StatefulWidget {
  final User user;
  const TeamListScreen({super.key, required this.user});

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
      _teamsFuture = _teamService.getAllTeams();
    });
  }

  void _navigateToDetails(Team team) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TeamDetailsScreen(team: team, user: widget.user),
    ));
  }

  void _navigateToCreate() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CreateTeamScreen(user: widget.user),
    ));
    if (result == true) {
      _loadTeams();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
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
                return ListTile(
                  title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(team.game),
                  onTap: () => _navigateToDetails(team),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}
