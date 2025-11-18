import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';

class SeedingScreen extends StatefulWidget {
  final String tournamentId;

  const SeedingScreen({super.key, required this.tournamentId});

  @override
  State<SeedingScreen> createState() => _SeedingScreenState();
}

class _SeedingScreenState extends State<SeedingScreen> {
  final _tournamentService = TournamentService();
  final _teamService = TeamService();
  late Future<Tournament?> _tournamentFuture;
  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _tournamentFuture = _tournamentService.getTournamentById(widget.tournamentId);
    _tournamentFuture.then((tournament) {
      if (tournament != null) {
        _teamService.getTeamsByIds(tournament.checkedInTeamIds).then((teams) {
          setState(() {
            // Sort teams based on existing seeding if available
            _teams = teams
              ..sort((a, b) =>
                  (tournament.seeding[a.id] ?? 999) - (tournament.seeding[b.id] ?? 999));
          });
        });
      }
    });
  }

  Future<void> _saveSeeding() async {
    final seeding = <String, int>{};
    for (int i = 0; i < _teams.length; i++) {
      seeding[_teams[i].id] = i + 1;
    }

    try {
      await _tournamentService.updateSeeding(widget.tournamentId, seeding);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seeding saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save seeding: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Seeding'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSeeding,
          )
        ],
      ),
      body: FutureBuilder<Tournament?>(
        future: _tournamentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_teams.isEmpty) {
            return const Center(
              child: Text('No checked-in teams to seed.'),
            );
          }
          return ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final team = _teams.removeAt(oldIndex);
                _teams.insert(newIndex, team);
              });
            },
            children: _teams.map((team) {
              final seed = _teams.indexOf(team) + 1;
              return ListTile(
                key: ValueKey(team.id),
                leading: Text('#$seed', style: const TextStyle(fontWeight: FontWeight.bold)),
                title: Text(team.name),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
