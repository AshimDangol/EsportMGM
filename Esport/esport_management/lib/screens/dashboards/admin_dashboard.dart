import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/clan_list_screen.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  final User user;
  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStatsGrid(),
          const SizedBox(height: 24),
          Text('Ongoing Tournaments', style: Theme.of(context).textTheme.headlineSmall),
          _buildOngoingTournaments(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final firestoreService = context.read<FirestoreService>();
    final clanService = context.read<ClanService>();
    final tournamentService = context.read<TournamentService>();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Total Users', firestoreService.getAllUsers().then((u) => u.length)),
        InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClanListScreen(user: widget.user))),
          child: _buildStatCard('Clans', clanService.getAllClans().then((c) => c.length)),
        ),
        _buildStatCard('Ongoing Tournaments', tournamentService.getAllTournaments().then((t) => t.length)),
      ],
    );
  }

  Widget _buildStatCard(String title, Future<int> future) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text(snapshot.data?.toString() ?? '0', style: Theme.of(context).textTheme.headlineMedium);
              },
            ),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingTournaments() {
    return FutureBuilder(
      future: Future.value(null),
      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      // Dummy data for now
      return const ListTile(title: Text('Intra-College Valorant Championship'));
    });
  }
}
