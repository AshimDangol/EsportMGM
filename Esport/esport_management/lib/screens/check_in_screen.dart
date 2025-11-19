import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';

class CheckInScreen extends StatefulWidget {
  final String tournamentId;
  const CheckInScreen({super.key, required this.tournamentId});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _tournamentService = TournamentService();
  final _clanService = ClanService();

  late Future<Tournament?> _tournamentFuture;
  Future<List<Clan>>? _registeredClansFuture;
  Set<String> _checkedInClanIds = {};

  @override
  void initState() {
    super.initState();
    _tournamentFuture = _tournamentService.getTournamentById(widget.tournamentId);
    _tournamentFuture.then((tournament) {
      if (tournament != null) {
        setState(() {
          _checkedInClanIds = Set<String>.from(tournament.checkedInClanIds);
          _registeredClansFuture = _clanService.getClansByIds(tournament.registeredClanIds);
        });
      }
    });
  }

  Future<void> _onCheckInChanged(String clanId, bool isCheckedIn) async {
    setState(() {
      if (isCheckedIn) {
        _checkedInClanIds.add(clanId);
      } else {
        _checkedInClanIds.remove(clanId);
      }
    });
    await _tournamentService.setClanCheckInStatus(widget.tournamentId, clanId, isCheckedIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Check-ins'),
      ),
      body: FutureBuilder<List<Clan>>(
        future: _registeredClansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Could not load clans.'));
          }

          final clans = snapshot.data!;
          if (clans.isEmpty) {
            return const Center(child: Text('No clans are registered for this tournament.'));
          }

          return ListView.builder(
            itemCount: clans.length,
            itemBuilder: (context, index) {
              final clan = clans[index];
              return CheckboxListTile(
                title: Text(clan.name),
                value: _checkedInClanIds.contains(clan.id),
                onChanged: (bool? value) {
                  if (value != null) {
                    _onCheckInChanged(clan.id, value);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
