import 'package:bson/bson.dart';
import 'package:esport_mgm/models/match.dart';
import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BracketView extends StatelessWidget {
  final List<Match> matches;
  final String tournamentId;
  final Function(Match)? onMatchTapped;

  const BracketView({
    super.key,
    required this.matches,
    required this.tournamentId,
    this.onMatchTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(child: Text('Bracket has not been generated yet.'));
    }

    final rounds = _groupMatchesByRound();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rounds.entries.map((entry) {
          return _buildRoundColumn(context, entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Map<int, List<Match>> _groupMatchesByRound() {
    final map = <int, List<Match>>{};
    for (final match in matches) {
      (map[match.roundNumber] ??= []).add(match);
    }
    return map;
  }

  Widget _buildRoundColumn(BuildContext context, int roundNumber, List<Match> roundMatches) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Round $roundNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
          ...roundMatches.map((match) => _buildMatchCard(context, match)),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Match match) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: InkWell(
        onTap: onMatchTapped != null ? () => onMatchTapped!(match) : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: 200,
            child: Column(
              children: [
                _buildClanRow(match.clan1Id, match.clan1Score),
                const Divider(height: 10, thickness: 1),
                _buildClanRow(match.clan2Id, match.clan2Score),
                const SizedBox(height: 10),
                _buildMatchFooter(context, match),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClanRow(String? clanId, int score) {
    final clanService = ClanService();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: FutureBuilder<Clan?>(
            future: clanId != null ? clanService.getClanById(clanId) : Future.value(null),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('...', style: TextStyle(fontSize: 16));
              }
              return Text(
                snapshot.data?.name ?? 'TBD',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ),
        Text(score.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMatchFooter(BuildContext context, Match match) {
    if (match.status == MatchStatus.completed) {
      return const Text('Completed', style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic));
    }
    if (match.scheduledTime != null) {
      return Text(
        DateFormat.yMd().add_jm().format(match.scheduledTime!.toLocal()),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      );
    }
    return GestureDetector(
      onTap: () => _showDateTimePicker(context, match),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 14, color: Colors.blue),
          SizedBox(width: 4),
          Text('Schedule', style: TextStyle(color: Colors.blue, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _showDateTimePicker(BuildContext context, Match match) async {
    final tournamentService = TournamentService();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (time == null) return;

    final finalDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    try {
      // Using match.id which is now a String
      await tournamentService.scheduleMatch(tournamentId, match.id, finalDateTime);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match Scheduled!')),
      );
      // A mechanism to refresh the parent view would be needed here
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule match: $e')),
      );
    }
  }
}
