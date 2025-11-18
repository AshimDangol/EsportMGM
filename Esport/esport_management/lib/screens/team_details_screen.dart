import 'package:esport_mgm/models/player_contract.dart';
import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/screens/add_player_screen.dart';
import 'package:esport_mgm/services/player_contract_service.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:esport_mgm/services/user_service.dart';
import 'package:flutter/material.dart';

class TeamDetailsScreen extends StatefulWidget {
  final String teamId;

  const TeamDetailsScreen({super.key, required this.teamId});

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  final _teamService = TeamService();
  final _contractService = PlayerContractService();
  final _userService = UserService();

  late Future<Team?> _teamFuture;
  late Future<List<PlayerContract>> _contractsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _teamFuture = _teamService.getTeamById(widget.teamId);
      _contractsFuture = _contractService.getContractsForTeam(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Details'),
      ),
      body: FutureBuilder<Team?>(
        future: _teamFuture,
        builder: (context, teamSnapshot) {
          if (teamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (teamSnapshot.hasError || !teamSnapshot.hasData) {
            return const Center(child: Text('Could not load team details.'));
          }

          final team = teamSnapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(team.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                const Text('Players', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: FutureBuilder<List<PlayerContract>>(
                    future: _contractsFuture,
                    builder: (context, contractsSnapshot) {
                      if (contractsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (contractsSnapshot.hasError || !contractsSnapshot.hasData) {
                        return const Center(child: Text('Could not load players.'));
                      }
                      final contracts = contractsSnapshot.data!;
                      if (contracts.isEmpty) {
                        return const Center(child: Text('No players on this team yet.'));
                      }

                      return ListView.builder(
                        itemCount: contracts.length,
                        itemBuilder: (context, index) {
                          final contract = contracts[index];
                          // This assumes you have a way to get player details from a user service
                          return FutureBuilder(
                            future: _userService.getUserByUid(contract.playerId),
                            builder: (context, userSnapshot) {
                              final playerName = userSnapshot.data?.displayName ?? 'Loading...';
                              return ListTile(
                                title: Text(playerName),
                                subtitle: Text('Contract: ${contract.startDate.toLocal().toString().substring(0, 10)} - ${contract.endDate.toLocal().toString().substring(0, 10)}'),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddPlayerScreen(teamId: widget.teamId),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
