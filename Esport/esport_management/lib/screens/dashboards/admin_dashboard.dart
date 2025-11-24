import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/clan_hub_screen.dart';
import 'package:esport_mgm/screens/player_list_screen.dart';
import 'package:esport_mgm/screens/tournament_details_screen.dart';
import 'package:esport_mgm/screens/tournament_list_screen.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  final User user;
  const AdminDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildQuickActions(context),
          _buildSectionTitle(context, 'Ongoing Tournaments'),
          _buildOngoingTournaments(context),
          _buildSectionTitle(context, 'My Bookmarked Clans'),
          _buildBookmarkedClans(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: [
        _quickActionButton(context, icon: Icons.shield_outlined, label: 'Clans', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClanHubScreen(user: user)))),
        _quickActionButton(context, icon: Icons.emoji_events_outlined, label: 'Tournaments', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => TournamentListScreen(user: user)))),
        _quickActionButton(context, icon: Icons.people_outline, label: 'Players', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlayerListScreen(user: user)))),
      ],
    );
  }

  Widget _quickActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 16)
      ),
    );
  }

  Widget _buildOngoingTournaments(BuildContext context) {
    final tournamentService = context.read<TournamentService>();
    return FutureBuilder<List<Tournament>>(
      future: tournamentService.getAllTournaments(), // You might want a more specific query here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tournaments currently running.'));
        }
        final tournaments = snapshot.data!;
        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              return TournamentCard(tournament: tournaments[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildBookmarkedClans(BuildContext context) {
    final clanService = context.read<ClanService>();
    return StreamBuilder<User?>(
      stream: context.read<FirestoreService>().getUserStream(user.id),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const SizedBox.shrink();
        final bookmarkedIds = userSnapshot.data!.bookmarkedClanIds;
        if (bookmarkedIds.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('You have no bookmarked clans.')));
        }
        return FutureBuilder<List<Clan>>(
          future: clanService.getClansByIds(bookmarkedIds),
          builder: (context, clanSnapshot) {
            if (!clanSnapshot.hasData) return const Center(child: CircularProgressIndicator());
            final clans = clanSnapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: clans.length,
              itemBuilder: (context, index) {
                final clan = clans[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.shield),
                    title: Text(clan.name),
                    subtitle: Text('${clan.memberIds.length} members'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  const TournamentCard({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TournamentDetailsScreen(tournamentId: tournament.id, user: context.read<User>()),
          )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/250x120.png/333/fff?text=Tournament'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tournament.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(tournament.game),
                    const SizedBox(height: 4),
                    Text(DateFormat.yMMMd().format(tournament.startDate)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
