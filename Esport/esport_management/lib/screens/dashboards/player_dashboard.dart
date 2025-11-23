import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/match.dart';
import 'package:esport_mgm/models/player_stats.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/training.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/clan_list_screen.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/player_stats_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:esport_mgm/services/training_service.dart';
import 'package:esport_mgm/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerDashboard extends StatefulWidget {
  final User user;
  const PlayerDashboard({super.key, required this.user});

  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  late Future<PlayerStats> _playerStatsFuture;
  late Future<List<Match>> _upcomingMatchesFuture;
  late Future<List<Training>> _trainingScheduleFuture;

  @override
  void initState() {
    super.initState();
    final playerStatsService = context.read<PlayerStatsService>();
    _playerStatsFuture = playerStatsService.getPlayerStats(widget.user.id);
    _upcomingMatchesFuture = _getUpcomingMatches();
    _trainingScheduleFuture = _getTrainingSchedule();
  }

  Future<List<Match>> _getUpcomingMatches() async {
    final userService = context.read<UserService>();
    final tournamentService = context.read<TournamentService>();

    final Clan? clan = await userService.getClanForUser(widget.user.id);
    if (clan == null) {
      return [];
    }

    final List<Tournament> tournaments = await tournamentService.getTournamentsForClan(clan.id);
    final List<Match> upcomingMatches = [];

    for (final tournament in tournaments) {
      for (final match in tournament.matches) {
        if (match.status == MatchStatus.pending &&
            (match.clan1Id == clan.id || match.clan2Id == clan.id)) {
          upcomingMatches.add(match);
        }
      }
    }

    return upcomingMatches;
  }

  Future<List<Training>> _getTrainingSchedule() async {
    final userService = context.read<UserService>();
    final trainingService = context.read<TrainingService>();

    final Clan? clan = await userService.getClanForUser(widget.user.id);
    if (clan == null) {
      return [];
    }

    return trainingService.getTrainingsForClan(clan.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Community'),
          _buildClanNavigation(),
          const SizedBox(height: 24),
          _buildSectionTitle('Upcoming Matches'),
          _buildUpcomingMatches(),
          const SizedBox(height: 24),
          _buildSectionTitle('Training Schedule'),
          _buildTrainingSchedule(),
          const SizedBox(height: 24),
          _buildSectionTitle('Your Performance'),
          _buildPerformanceCard(),
        ],
      ),
    );
  }

  Widget _buildClanNavigation() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.group),
        title: const Text('Clans'),
        subtitle: const Text('Browse and join clans'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ClanListScreen(user: widget.user),
          ));
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }

  Widget _buildUpcomingMatches() {
    return FutureBuilder<List<Match>>(
      future: _upcomingMatchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Could not fetch matches.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Card(
            child: ListTile(
              title: Text('No upcoming matches'),
            ),
          );
        }

        final matches = snapshot.data!;
        final clanService = context.read<ClanService>();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            final opponentClanId = match.clan1Id == widget.user.id ? match.clan2Id : match.clan1Id;

            return Card(
              child: ListTile(
                leading: const Icon(Icons.gamepad),
                title: FutureBuilder<Clan?>(
                  future: clanService.getClanById(opponentClanId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('vs. ...');
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('vs. Unknown');
                    }
                    return Text('vs. ${snapshot.data!.name}');
                  },
                ),
                subtitle: Text(match.scheduledTime?.toString() ?? 'TBD'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrainingSchedule() {
    return FutureBuilder<List<Training>>(
      future: _trainingScheduleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Could not fetch training schedule.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Card(
            child: ListTile(
              title: Text('No training scheduled'),
            ),
          );
        }

        final trainings = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trainings.length,
          itemBuilder: (context, index) {
            final training = trainings[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(training.title),
                subtitle: Text(training.dateTime.toString()),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<PlayerStats>(
          future: _playerStatsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Could not fetch stats.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No stats available.'));
            }

            final stats = snapshot.data!;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [const Text('K/D/A'), Text(stats.kda.toStringAsFixed(2))]),
                    Column(children: [const Text('Win Rate'), Text('${stats.winRate.toStringAsFixed(1)}%')]),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
