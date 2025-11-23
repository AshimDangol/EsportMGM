import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/match.dart';
import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/player_stats.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:esport_mgm/services/player_stats_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:esport_mgm/widgets/player_stat_input_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MatchDetailsScreen extends StatefulWidget {
  final Match match;
  final String tournamentId;

  const MatchDetailsScreen({
    super.key,
    required this.match,
    required this.tournamentId,
  });

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  Future<Clan?>? _clan1Future;
  Future<Clan?>? _clan2Future;
  late Future<Tournament?> _tournamentFuture;
  final Map<String, PlayerStats> _statsMap = {};

  @override
  void initState() {
    super.initState();
    final clanService = context.read<ClanService>();
    if (widget.match.clan1Id != null) {
      _clan1Future = clanService.getClanById(widget.match.clan1Id!);
    }
    if (widget.match.clan2Id != null) {
      _clan2Future = clanService.getClanById(widget.match.clan2Id!);
    }
    _tournamentFuture = context.read<TournamentService>().getTournamentById(widget.tournamentId);
  }

  void _refresh() {
    final clanService = context.read<ClanService>();
    setState(() {
      if (widget.match.clan1Id != null) {
        _clan1Future = clanService.getClanById(widget.match.clan1Id!);
      }
      if (widget.match.clan2Id != null) {
        _clan2Future = clanService.getClanById(widget.match.clan2Id!);
      }
      _tournamentFuture = context.read<TournamentService>().getTournamentById(widget.tournamentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Match ${widget.match.matchNumber}'),
      ),
      body: FutureBuilder<Tournament?>(
        future: _tournamentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tournament = snapshot.data;
          final bool isTournamentAdmin = tournament?.adminId == user.id;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Round', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.match.roundNumber.toString(), style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                _buildScoreCard(),
                const SizedBox(height: 30),
                if (isTournamentAdmin && widget.match.status != MatchStatus.completed) ...[
                  ElevatedButton(
                    onPressed: () => _showUpdateScoreDialog(),
                    child: const Text('Update Score'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showUpdateStatsDialog(),
                    child: const Text('Update Player Stats'),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildClanDisplay(_clan1Future, widget.match.clan1Score),
        const Text('VS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        _buildClanDisplay(_clan2Future, widget.match.clan2Score),
      ],
    );
  }

  Widget _buildClanDisplay(Future<Clan?>? clanFuture, int score) {
    return Column(
      children: [
        FutureBuilder<Clan?>(
          future: clanFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 60, width: 60, child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text('TBD', style: TextStyle(fontSize: 22));
            }
            final clan = snapshot.data!;
            return Column(
              children: [
                const Icon(Icons.shield, size: 60, color: Colors.grey),
                const SizedBox(height: 8),
                Text(clan.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Text(score.toString(), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showUpdateScoreDialog() {
    final clan1ScoreController = TextEditingController(text: widget.match.clan1Score.toString());
    final clan2ScoreController = TextEditingController(text: widget.match.clan2Score.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Score'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<Clan?>(
                  future: _clan1Future,
                  builder: (context, snapshot) {
                    return TextFormField(
                      controller: clan1ScoreController,
                      decoration: InputDecoration(labelText: snapshot.data?.name ?? 'Clan 1 Score'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter score' : null,
                    );
                  },
                ),
                FutureBuilder<Clan?>(
                  future: _clan2Future,
                  builder: (context, snapshot) {
                    return TextFormField(
                      controller: clan2ScoreController,
                      decoration: InputDecoration(labelText: snapshot.data?.name ?? 'Clan 2 Score'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter score' : null,
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final score1 = int.parse(clan1ScoreController.text);
                  final score2 = int.parse(clan2ScoreController.text);

                  try {
                    await context.read<TournamentService>().updateMatchScore(
                      widget.tournamentId,
                      widget.match.id,
                      score1,
                      score2,
                    );
                    _refresh();
                    if (mounted) {
                      Navigator.pop(context); // Close the dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Score updated successfully!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update score: $e')),
                      );
                    }
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

  void _showUpdateStatsDialog() async {
    final clan1 = await _clan1Future;
    final clan2 = await _clan2Future;
    if (clan1 == null || clan2 == null) return;

    final playerService = context.read<PlayerService>();
    final clan1Players = await playerService.getPlayersByClan(clan1.id);
    final clan2Players = await playerService.getPlayersByClan(clan2.id);

    final allPlayers = [...clan1Players, ...clan2Players];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Player Stats'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: allPlayers
                  .map((player) => PlayerStatInputRow(
                        player: player,
                        onStatsChanged: (stats) {
                          _statsMap[player.id] = stats;
                        },
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final playerStatsService = context.read<PlayerStatsService>();
                await playerStatsService.updateStatsForPlayers(_statsMap);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Player stats updated!')),
                  );
                }
              },
              child: const Text('Save All'),
            ),
          ],
        );
      },
    );
  }
}
