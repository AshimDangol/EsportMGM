import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:flutter/material.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late final TeamService _teamService;
  Future<List<Team>>? _teamsFuture;
  Region _selectedRegion = Region.global;

  @override
  void initState() {
    super.initState();
    _teamService = TeamService(DBService.instance.db);
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _teamsFuture = _teamService.getAllTeams(region: _selectedRegion);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_selectedRegion.toString().split('.').last.toUpperCase()} Rankings'),
        actions: [
          _buildRegionMenu(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTeams,
        child: FutureBuilder<List<Team>>(
          future: _teamsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final teams = snapshot.data ?? [];
            if (teams.isEmpty) {
              return const Center(child: Text('No teams found in this region.'));
            }

            teams.sort((a, b) {
              final pointsCompare = b.seasonalPoints.compareTo(a.seasonalPoints);
              if (pointsCompare != 0) return pointsCompare;
              return b.eloRating.compareTo(a.eloRating);
            });

            return ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                final tierText = team.tier.toString().split('.').last;
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('#${index + 1}'),
                  ),
                  title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Tier: $tierText\nSeasonal Points: ${team.seasonalPoints}',
                  ),
                  trailing: Text(
                    'ELO: ${team.eloRating}',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  PopupMenuButton<Region> _buildRegionMenu() {
    return PopupMenuButton<Region>(
      icon: const Icon(Icons.public),
      onSelected: (Region region) {
        setState(() {
          _selectedRegion = region;
        });
        _loadTeams();
      },
      itemBuilder: (BuildContext context) {
        return Region.values.map((Region region) {
          return PopupMenuItem<Region>(
            value: region,
            child: Text(region.toString().split('.').last),
          );
        }).toList();
      },
    );
  }
}
