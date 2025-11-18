import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';

class CheckInScreen extends StatefulWidget {
  final String tournamentId;

  const CheckInScreen({super.key, required this.tournamentId});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _tournamentService = TournamentService();
  final _teamService = TeamService();

  late Future<Tournament?> _tournamentFuture;
  late Future<List<Team>> _registeredTeamsFuture;
  final Set<String> _checkedInTeamIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _tournamentFuture = _tournamentService.getTournamentById(widget.tournamentId);
    _tournamentFuture.then((tournament) {
      if (tournament != null) {
        setState(() {
          _checkedInTeamIds.addAll(tournament.checkedInTeamIds);
          _registeredTeamsFuture = _teamService.getTeamsByIds(tournament.registeredTeamIds);
        });
      }
    });
  }

  Future<void> _toggleCheckIn(String teamId) async {
    final isCheckedIn = _checkedInTeamIds.contains(teamId);
    try {
      await _tournamentService.setTeamCheckInStatus(
        widget.tournamentId,
        teamId,
        !isCheckedIn,
      );
      setState(() {
        if (isCheckedIn) {
          _checkedInTeamIds.remove(teamId);
        } else {
          _checkedInTeamIds.add(teamId);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Check-ins'),
      ),
      body: FutureBuilder<Tournament?>(
        future: _tournamentFuture,
        builder: (context, tournamentSnapshot) {
          if (tournamentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (tournamentSnapshot.hasError || !tournamentSnapshot.hasData) {
            return const Center(child: Text('Could not load tournament.'));
          }

          return FutureBuilder<List<Team>>(
            future: _registeredTeamsFuture,
            builder: (context, teamsSnapshot) {
              if (teamsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (teamsSnapshot.hasError || !teamsSnapshot.hasData || teamsSnapshot.data!.isEmpty) {
                return const Center(child: Text('No teams registered yet.'));
              }

              final teams = teamsSnapshot.data!;
              return ListView.builder(
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  final isCheckedIn = _checkedInTeamIds.contains(team.id);
                  return SwitchListTile(
                    title: Text(team.name),
                    value: isCheckedIn,
                    onChanged: (bool value) {
                      _toggleCheckIn(team.id);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
