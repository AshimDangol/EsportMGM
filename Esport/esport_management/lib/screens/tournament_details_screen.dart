import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/check_in_screen.dart';
import 'package:esport_mgm/screens/match_details_screen.dart';
import 'package:esport_mgm/screens/seeding_screen.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:esport_mgm/widgets/bracket_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TournamentDetailsScreen extends StatefulWidget {
  final String tournamentId;
  final User user;

  const TournamentDetailsScreen({super.key, required this.tournamentId, required this.user});

  @override
  State<TournamentDetailsScreen> createState() => _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen> {
  final _clanService = ClanService();
  final _tournamentService = TournamentService();

  late Future<Tournament?> _tournamentFuture;

  @override
  void initState() {
    super.initState();
    _loadTournamentData();
  }

  void _loadTournamentData() {
    _tournamentFuture = _tournamentService.getTournamentById(widget.tournamentId);
  }

  void _refreshTournament() {
    setState(() {
      _loadTournamentData();
    });
  }

  Future<void> _generateBracket() async {
    try {
      await _tournamentService.generateBracket(widget.tournamentId);
      _refreshTournament();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate bracket: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tournament Details"),
      ),
      body: FutureBuilder<Tournament?>(
        future: _tournamentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Tournament not found or failed to load.'));
          }

          final tournament = snapshot.data!;
          final bool isUserAdmin = tournament.adminId == widget.user.id;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tournament.name, style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 16),
                          Text('Game: ${tournament.game}', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 10),
                          Text('Date: ${DateFormat.yMMMEd().format(tournament.startDate.toLocal())}'),
                          const SizedBox(height: 10),
                          Text('Venue: ${tournament.venue ?? 'Online'}'),
                          const SizedBox(height: 10),
                          Text('Prize Pool: \$${tournament.prizePool.toStringAsFixed(2)}'),
                          const SizedBox(height: 10),
                          Text('Format: ${tournament.format.name}'),
                          const SizedBox(height: 10),
                          Text('Description: ${tournament.description}'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _showRulesDialog(tournament.rules),
                            child: const Text('View Rules'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isUserAdmin && tournament.matches.isEmpty)
                            ElevatedButton(
                              onPressed: _generateBracket,
                              child: const Text('Generate Bracket'),
                            ),
                          const SizedBox(height: 20),
                          const Text('Bracket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          BracketView(
                            matches: tournament.matches,
                            tournamentId: tournament.id,
                            onMatchTapped: (match) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MatchDetailsScreen(match: match, tournamentId: tournament.id),
                              ));
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text('Registered Clans:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          _buildClansList(tournament.registeredClanIds, 'No clans have registered yet.'),
                          const SizedBox(height: 20),
                          const Text('Checked-in Clans:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          _buildClansList(tournament.checkedInClanIds, 'No clans have checked in yet.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRulesDialog(String rules) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tournament Rules'),
        content: SingleChildScrollView(child: Text(rules)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildClansList(List<String> clanIds, String emptyMessage) {
    if (clanIds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(emptyMessage),
      );
    }

    return FutureBuilder<List<Clan>>(
      future: _clanService.getClansByIds(clanIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.only(top: 8.0), child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Could not load clans.'));
        }
        final clans = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: clans.map((clan) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(clan.name, style: const TextStyle(fontSize: 16)),
          )).toList(),
        );
      },
    );
  }
}
