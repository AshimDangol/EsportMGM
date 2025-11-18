import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/screens/check_in_screen.dart';
import 'package:esport_mgm/screens/seeding_screen.dart';
import 'package:esport_mgm/services/auth_service.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:esport_mgm/widgets/bracket_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TournamentDetailsScreen extends StatefulWidget {
  final String tournamentId;

  const TournamentDetailsScreen({super.key, required this.tournamentId});

  @override
  State<TournamentDetailsScreen> createState() => _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen> {
  final _teamService = TeamService();
  final _tournamentService = TournamentService();
  final _authService = AuthService();

  late Future<Tournament?> _tournamentFuture;
  Future<List<Team>>? _userTeamsFuture;

  @override
  void initState() {
    super.initState();
    _loadTournamentData();
    final userId = _authService.getCurrentUser()?.id.toHexString();
    if (userId != null) {
      _userTeamsFuture = _teamService.getUserTeams(userId);
    }
  }

  void _loadTournamentData() {
    _tournamentFuture = _tournamentService.getTournamentById(widget.tournamentId);
  }

  void _refreshTournament() {
    setState(() {
      _loadTournamentData();
    });
  }

  Future<void> _generateBracket() async {
    try {
      await _tournamentService.generateBracket(widget.tournamentId);
      _refreshTournament();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate bracket: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tournament Details"),
        actions: [
          // For now, assuming any logged-in user can manage check-ins.
          // You can add role-based logic here later.
          if (_authService.getCurrentUser() != null)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Manage Check-ins',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CheckInScreen(tournamentId: widget.tournamentId),
                  ),
                );
                if (result == true) {
                  _refreshTournament();
                }
              },
            ),
          if (_authService.getCurrentUser() != null)
            IconButton(
              icon: const Icon(Icons.format_list_numbered),
              tooltip: 'Manage Seeding',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        SeedingScreen(tournamentId: widget.tournamentId),
                  ),
                );
                _refreshTournament();
              },
            ),
        ],
      ),
      body: FutureBuilder<Tournament?>(
        future: _tournamentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(
                child: Text('Tournament not found or failed to load.'));
          }

          final tournament = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tournament.name,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Text('Game: ${tournament.game}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(
                      'Date: ${DateFormat.yMMMEd().format(tournament.date.toLocal())}'),
                  const SizedBox(height: 10),
                  Text('Prize Pool: \$${tournament.prizePool.toStringAsFixed(2)}'),
                  const SizedBox(height: 10),
                  Text('Description: ${tournament.description}'),
                  const SizedBox(height: 10),
                  Text('Format: ${tournament.format.toString().split('.').last}'),
                  const SizedBox(height: 10),
                  const Text('Rules:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(tournament.rules),
                  const SizedBox(height: 20),
                  if (_authService.getCurrentUser() != null)
                    ElevatedButton(
                      onPressed: _generateBracket,
                      child: const Text('Generate Bracket'),
                    ),
                  const SizedBox(height: 20),
                  const Text('Bracket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  BracketView(matches: tournament.matches, tournamentId: tournament.id),
                  const SizedBox(height: 20),
                  const Text('Registered Teams:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildTeamsList(tournament.registeredTeamIds, 'No teams have registered yet.'),
                  const SizedBox(height: 20),
                   const Text('Checked-in Teams:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildTeamsList(tournament.checkedInTeamIds, 'No teams have checked in yet.'),
                  const SizedBox(height: 20),
                  if (_authService.getCurrentUser()?.id != null)
                    _buildRegisterTeamButton(tournament),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamsList(List<String> teamIds, String emptyMessage) {
    if (teamIds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(emptyMessage),
      );
    }

    return FutureBuilder<List<Team>>(
      future: _teamService.getTeamsByIds(teamIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Could not load teams.'),
          );
        }
        final teams = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: teams
              .map((team) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(team.name, style: const TextStyle(fontSize: 16)),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildRegisterTeamButton(Tournament tournament) {
    return FutureBuilder<List<Team>>(
      future: _userTeamsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // No teams to register
        }

        return Center(
          child: ElevatedButton(
            onPressed: () => _showTeamSelectionDialog(snapshot.data!, tournament),
            child: const Text('Register Your Team'),
          ),
        );
      },
    );
  }

  void _showTeamSelectionDialog(List<Team> userTeams, Tournament tournament) {
    String? selectedTeamId;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          final availableTeams = userTeams
              .where((team) => !tournament.registeredTeamIds.contains(team.id))
              .toList();

          if (availableTeams.isEmpty) {
            return AlertDialog(
              title: const Text('Register a Team'),
              content: const Text(
                  'All of your teams are already registered for this tournament.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context), child: const Text('OK'))
              ],
            );
          }

          return AlertDialog(
            title: const Text('Select a Team to Register'),
            content: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select a team'),
              value: selectedTeamId,
              items: availableTeams.map((team) {
                return DropdownMenuItem<String>(
                  value: team.id,
                  child: Text(team.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTeamId = value;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              if (isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: selectedTeamId == null
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            await _tournamentService.registerTeam(
                                tournament.id, selectedTeamId!);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Team Registered!')),
                              );
                              _refreshTournament();
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to register: $e')),
                              );
                            }
                          }
                        },
                  child: const Text('Register'),
                ),
            ],
          );
        },
      ),
    );
  }
}
