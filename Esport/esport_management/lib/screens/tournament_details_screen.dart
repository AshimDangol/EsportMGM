import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/check_in_screen.dart';
import 'package:esport_mgm/screens/match_details_screen.dart';
import 'package:esport_mgm/screens/seeding_screen.dart';
import 'package:esport_mgm/screens/ticketing/ticket_purchase_screen.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:esport_mgm/widgets/bracket_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TournamentDetailsScreen extends StatefulWidget {
  final String tournamentId;
  final User user;

  const TournamentDetailsScreen(
      {super.key, required this.tournamentId, required this.user});

  @override
  State<TournamentDetailsScreen> createState() =>
      _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen> {
  late Future<Tournament?> _tournamentFuture;

  @override
  void initState() {
    super.initState();
    _loadTournamentData();
  }

  void _loadTournamentData() {
    _tournamentFuture =
        context.read<TournamentService>().getTournamentById(widget.tournamentId);
  }

  void _refreshTournament() {
    setState(() {
      _loadTournamentData();
    });
  }

  Future<bool?> _showConfirmationDialog(
      {required String title, required String content}) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Confirm'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateBracket() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Generate Bracket',
      content: 'Are you sure? This will create the initial match pairings and cannot be undone.',
    );
    if (confirmed != true) return;

    try {
      await context
          .read<TournamentService>()
          .generateBracket(widget.tournamentId);
      _refreshTournament();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate bracket: $e')),
        );
      }
    }
  }

  Future<void> _removeClanFromTournament(Clan clan) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Remove Clan',
      content: 'Are you sure you want to remove ${clan.name} from the tournament?',
    );
    if (confirmed != true) return;
    try {
      await context.read<TournamentService>().unregisterClanFromTournament(widget.tournamentId, clan.id);
      _refreshTournament();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove clan: $e')),
        );
      }
    }
  }

  Future<void> _removePlayerFromTournament(User player) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Remove Player',
      content: 'Are you sure you want to remove ${player.email} from the tournament?',
    );
    if (confirmed != true) return;
    try {
      await context.read<TournamentService>().removePlayerFromTournament(widget.tournamentId, player.id);
      _refreshTournament();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove player: $e')),
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
            return const Center(
                child: Text('Tournament not found or failed to load.'));
          }

          final tournament = snapshot.data!;
          final bool isTournamentAdmin = tournament.adminId == widget.user.id;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(tournament),
                  const SizedBox(height: 20),
                  if (isTournamentAdmin) _buildAdminPanel(tournament),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bracket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          BracketView(
                            matches: tournament.matches,
                            tournamentId: tournament.id,
                            onMatchTapped: (match) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MatchDetailsScreen(
                                    match: match, tournamentId: tournament.id),
                              ));
                            },
                          ),
                          const Divider(height: 40),
                          const Text('Registered Clans & Players', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          _buildParticipantList(tournament, isTournamentAdmin),
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

  Card _buildHeaderCard(Tournament tournament) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tournament.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.videogame_asset), title: Text(tournament.game, style: const TextStyle(fontSize: 18))),
            ListTile(leading: const Icon(Icons.calendar_today), title: Text('Date: ${DateFormat.yMMMEd().format(tournament.startDate.toLocal())}')),
            ListTile(leading: const Icon(Icons.location_on), title: Text('Venue: ${tournament.venue ?? 'Online'}')),
            ListTile(leading: const Icon(Icons.emoji_events), title: Text('Prize Pool: \$${tournament.prizePool.toStringAsFixed(2)}')),
            ListTile(leading: const Icon(Icons.gavel), title: Text('Format: ${tournament.format.name}')),
            if (tournament.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
                child: Text(tournament.description),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.rule),
                  onPressed: () => _showRulesDialog(tournament.rules),
                  label: const Text('Rules'),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TicketPurchaseScreen(
                          tournament: tournament,
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                  label: const Text('Tickets'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPanel(Tournament tournament) {
    return Card(
      elevation: 4,
      color: Colors.blueGrey[50],
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CheckInScreen(tournament: tournament),)).then((_) => _refreshTournament()), child: const Text('Check-ins')),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SeedingScreen(tournamentId: tournament.id),)).then((_) => _refreshTournament()), child: const Text('Seeding')),
            if (tournament.matches.isEmpty)
              ElevatedButton(onPressed: _generateBracket, child: const Text('Generate Bracket')),
          ],
        ),
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
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildParticipantList(Tournament tournament, bool isTournamentAdmin) {
    if (tournament.registeredClanIds.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No clans have registered yet.')));
    }

    return FutureBuilder<List<Clan>>(
      future: context.read<ClanService>().getClansByIds(tournament.registeredClanIds),
      builder: (context, clanSnapshot) {
        if (clanSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (clanSnapshot.hasError || !clanSnapshot.hasData) {
          return const Center(child: Text('Could not load clan data.'));
        }
        final clans = clanSnapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: clans.length,
          itemBuilder: (context, index) {
            final clan = clans[index];
            final bool isClanOwner = clan.ownerId == widget.user.id;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                leading: CircleAvatar(child: Text((index + 1).toString())),
                title: Text(clan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: isTournamentAdmin
                    ? IconButton(
                        tooltip: 'Remove clan from tournament',
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _removeClanFromTournament(clan),
                      )
                    : null,
                children: [
                  FutureBuilder<List<User>>(
                    future: context.read<FirestoreService>().getUsers(clan.memberIds.where((id) => tournament.participatingPlayerIds.contains(id)).toList()),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      }
                      if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
                        return const ListTile(title: Text('No players from this clan are participating.'));
                      }
                      final players = userSnapshot.data!;
                      return Column(
                        children: players.map((player) {
                          final bool canManagePlayer = isTournamentAdmin || isClanOwner;
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.person, size: 20),
                            title: Text(player.email),
                            trailing: canManagePlayer
                                ? IconButton(
                                    tooltip: 'Remove player from tournament',
                                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                                    onPressed: () => _removePlayerFromTournament(player),
                                  )
                                : null,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
