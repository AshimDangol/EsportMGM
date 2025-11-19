import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';

class SeedingScreen extends StatefulWidget {
  final String tournamentId;
  const SeedingScreen({super.key, required this.tournamentId});

  @override
  State<SeedingScreen> createState() => _SeedingScreenState();
}

class _SeedingScreenState extends State<SeedingScreen> {
  final _tournamentService = TournamentService();
  final _clanService = ClanService();
  Map<String, int> _seeding = {};
  List<Clan> _clans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeedingData();
  }

  Future<void> _loadSeedingData() async {
    final tournament = await _tournamentService.getTournamentById(widget.tournamentId);
    if (tournament != null) {
      _clanService.getClansByIds(tournament.checkedInClanIds).then((clans) {
        setState(() {
          _clans = clans;
          _seeding = Map<String, int>.from(tournament.seeding);
          _isLoading = false;
        });
      });
    }
  }

  Future<void> _saveSeeding() async {
    try {
      await _tournamentService.updateSeeding(widget.tournamentId, _seeding);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seeding saved!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save seeding: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Seeding'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSeeding,
            tooltip: 'Save Seeding',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView.builder(
              itemCount: _clans.length,
              itemBuilder: (context, index) {
                final clan = _clans[index];
                return ListTile(
                  key: ValueKey(clan.id),
                  title: Text(clan.name),
                  leading: Text('#${_seeding[clan.id] ?? index + 1}'),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final clan = _clans.removeAt(oldIndex);
                  _clans.insert(newIndex, clan);

                  // Update seeding map
                  final newSeeding = <String, int>{};
                  for (int i = 0; i < _clans.length; i++) {
                    newSeeding[_clans[i].id] = i + 1;
                  }
                  _seeding = newSeeding;
                });
              },
            ),
    );
  }
}
