import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TournamentRegistrationScreen extends StatefulWidget {
  const TournamentRegistrationScreen({super.key});

  @override
  State<TournamentRegistrationScreen> createState() => _TournamentRegistrationScreenState();
}

class _TournamentRegistrationScreenState extends State<TournamentRegistrationScreen> {
  late Future<List<Tournament>> _tournamentsFuture;

  @override
  void initState() {
    super.initState();
    _tournamentsFuture = context.read<TournamentService>().getAllTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register for Tournament'),
      ),
      body: FutureBuilder<List<Tournament>>(
        future: _tournamentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tournaments available.'));
          }

          final tournaments = snapshot.data!;
          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              return ListTile(
                title: Text(tournament.name),
                subtitle: Text(tournament.game),
                onTap: () => Navigator.of(context).pop(tournament),
              );
            },
          );
        },
      ),
    );
  }
}
