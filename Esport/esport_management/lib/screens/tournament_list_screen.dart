import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/create_tournament_screen.dart';
import 'package:esport_mgm/screens/edit_tournament_screen.dart';
import 'package:esport_mgm/screens/join_tournament_screen.dart';
import 'package:esport_mgm/screens/tournament_details_screen.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TournamentListScreen extends StatefulWidget {
  final User user;
  const TournamentListScreen({super.key, required this.user});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen> {
  late Future<List<Tournament>> _tournamentsFuture;

  @override
  void initState() {
    super.initState();
    _tournamentsFuture = context.read<TournamentService>().getAllTournaments();
  }

  void _refreshTournaments() {
    setState(() {
      _tournamentsFuture = context.read<TournamentService>().getAllTournaments();
    });
  }

  void _navigateToCreateScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTournamentScreen(),
      ),
    );

    if (result == true) {
      _refreshTournaments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        actions: [
          IconButton(
            tooltip: 'Join with Code',
            icon: const Icon(Icons.group_add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => JoinTournamentScreen(user: widget.user))),
          ),
        ],
      ),
      body: FutureBuilder<List<Tournament>>(
        future: _tournamentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tournaments found.'));
          }

          final tournaments = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              return TournamentListItem(tournament: tournament, user: widget.user, onAction: _refreshTournaments);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateScreen,
        label: const Text('Create'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class TournamentListItem extends StatelessWidget {
  final Tournament tournament;
  final User user;
  final VoidCallback onAction; // To refresh the list after an action

  const TournamentListItem({super.key, required this.tournament, required this.user, required this.onAction});

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailsScreen(tournamentId: tournament.id, user: user),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTournamentScreen(tournament: tournament, user: user),
      ),
    );

    if (result == true) {
      onAction();
    }
  }

  void _deleteTournament(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tournament?'),
        content: Text('Are you sure you want to delete "${tournament.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red), onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<TournamentService>().deleteTournament(tournament.id);
      onAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUserAdmin = tournament.adminId == user.id;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateToDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(color: Colors.blueGrey, image: DecorationImage(image: NetworkImage('https://via.placeholder.com/400x150.png/2C3E50/FFFFFF?Text=Tournament'), fit: BoxFit.cover)),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tournament.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(tournament.game, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                   Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(DateFormat.yMMMd().format(tournament.startDate)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('\$${tournament.prizePool.toStringAsFixed(0)} Prize Pool'),
                    ],
                  ),
                ],
              ),
            ),
             if (isUserAdmin)
              Container(
                color: Colors.grey.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18), 
                      label: const Text('Edit'), 
                      onPressed: () => _navigateToEditScreen(context),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 18), 
                      label: const Text('Delete'), 
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => _deleteTournament(context),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
