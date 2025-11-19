import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/edit_tournament_screen.dart';
import 'package:esport_mgm/screens/join_tournament_screen.dart';
import 'package:esport_mgm/screens/tournament_details_screen.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';

class TournamentListScreen extends StatefulWidget {
  final User user;
  const TournamentListScreen({super.key, required this.user});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen> {
  final TournamentService _tournamentService = TournamentService();
  late Future<List<Tournament>> _tournamentsFuture;

  @override
  void initState() {
    super.initState();
    _tournamentsFuture = _tournamentService.getAllTournaments();
  }

  void _refreshTournaments() {
    setState(() {
      _tournamentsFuture = _tournamentService.getAllTournaments();
    });
  }

  void _navigateToDetailsScreen(Tournament tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailsScreen(tournamentId: tournament.id, user: widget.user),
      ),
    );
  }

  void _navigateToEditScreen([Tournament? tournament]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTournamentScreen(user: widget.user, tournament: tournament),
      ),
    );
    _refreshTournaments(); // Refresh the list after returning
  }

  void _navigateAndJoinTournament() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JoinTournamentScreen(user: widget.user),
      ),
    );
  }

  void _deleteTournament(Tournament tournament) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tournament?'),
        content: Text('Are you sure you want to delete "${tournament.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await _tournamentService.deleteTournament(tournament.id);
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
            icon: const Icon(Icons.group_add),
            onPressed: _navigateAndJoinTournament,
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
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              final bool isUserAdmin = tournament.adminId == widget.user.id;
              return ListTile(
                title: Text(tournament.name),
                subtitle: Text(tournament.game),
                onTap: () => _navigateToDetailsScreen(tournament),
                trailing: isUserAdmin
                    ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _navigateToEditScreen(tournament);
                          } else if (value == 'delete') {
                            _deleteTournament(tournament);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      )
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
