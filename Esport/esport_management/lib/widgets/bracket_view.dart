import 'package:esport_mgm/models/match.dart';
import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BracketView extends StatelessWidget {
  final String tournamentId;
  final List<Match> matches;
  final TeamService _teamService = TeamService();
  final TournamentService _tournamentService = TournamentService();

  BracketView({super.key, required this.matches, required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(child: Text('Bracket has not been generated yet.'));
    }

    // Group matches by round
    final rounds = <int, List<Match>>{};
    for (final match in matches) {
      (rounds[match.roundNumber] ??= []).add(match);
    }

    return Column(
      children: rounds.entries.map((entry) {
        final roundNumber = entry.key;
        final roundMatches = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Round $roundNumber', style: Theme.of(context).textTheme.headlineSmall),
            ),
            ...roundMatches.map((match) => _buildMatchCard(context, match)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMatchCard(BuildContext context, Match match) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _showScoreDialog(context, match),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTeamRow(context, match.team1Id, match.team1Score),
              const Divider(),
              _buildTeamRow(context, match.team2Id, match.team2Score),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match.scheduledTime == null
                        ? 'Not scheduled'
                        : DateFormat.yMd().add_jm().format(match.scheduledTime!.toLocal()),
                  ),
                  IconButton(
                    icon: const Icon(Icons.schedule),
                    onPressed: () => _showScheduleDialog(context, match),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow(BuildContext context, String? teamId, int score) {
    if (teamId == null) {
      return const Text('BYE');
    }

    return FutureBuilder<Team?>(
      future: _teamService.getTeamById(teamId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        final teamName = snapshot.data?.name ?? 'Unknown Team';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(teamName, style: const TextStyle(fontSize: 16)),
            Text(score.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        );
      },
    );
  }

  Future<void> _showScheduleDialog(BuildContext context, Match match) async {
    final selectedDateTime = await showDatePicker(
      context: context,
      initialDate: match.scheduledTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedDateTime != null && context.mounted) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(match.scheduledTime ?? DateTime.now()),
      );

      if (selectedTime != null) {
        final finalDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        try {
          await _tournamentService.scheduleMatch(tournamentId, match.id, finalDateTime);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Match scheduled!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to schedule match: $e')),
          );
        }
      }
    }
  }

  Future<void> _showScoreDialog(BuildContext context, Match match) async {
    final team1ScoreController = TextEditingController(text: match.team1Score.toString());
    final team2ScoreController = TextEditingController(text: match.team2Score.toString());

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Scores'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: team1ScoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Team 1 Score'),
              ),
              TextField(
                controller: team2ScoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Team 2 Score'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final team1Score = int.tryParse(team1ScoreController.text) ?? 0;
                final team2Score = int.tryParse(team2ScoreController.text) ?? 0;

                try {
                  await _tournamentService.updateMatchScore(
                    tournamentId,
                    match.id,
                    team1Score,
                    team2Score,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Scores updated!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update scores: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
