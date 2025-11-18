import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/edit_tournament_screen.dart';
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

  bool get _canCreateTournaments {
    return widget.user.role == UserRole.admin || widget.user.role == UserRole.host;
  }

  @override
  void initState() {
    super.initState();
    _tournamentsFuture = _tournamentService.getTournaments();
  }

  void _refreshTournaments() {
    setState(() {
      _tournamentsFuture = _tournamentService.getTournaments();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
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
              return ListTile(
                title: Text(tournament.name),
                subtitle: Text(tournament.game),
                onTap: () => _navigateToEditScreen(tournament),
              );
            },
          );
        },
      ),
      floatingActionButton: _canCreateTournaments
          ? FloatingActionButton(
              onPressed: () => _navigateToEditScreen(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
