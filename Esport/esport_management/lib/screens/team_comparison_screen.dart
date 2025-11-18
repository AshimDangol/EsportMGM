import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:flutter/material.dart';

class TeamComparisonScreen extends StatefulWidget {
  const TeamComparisonScreen({super.key});

  @override
  State<TeamComparisonScreen> createState() => _TeamComparisonScreenState();
}

class _TeamComparisonScreenState extends State<TeamComparisonScreen> {
  late final TeamService _teamService;
  List<Team> _allTeams = [];
  Team? _selectedTeam1;
  Team? _selectedTeam2;

  @override
  void initState() {
    super.initState();
    _teamService = TeamService(DBService.instance.db);
    _loadAllTeams();
  }

  Future<void> _loadAllTeams() async {
    final teams = await _teamService.getAllTeams();
    setState(() {
      _allTeams = teams;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Comparison'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTeamSelectors(),
            const Divider(height: 32),
            if (_selectedTeam1 != null && _selectedTeam2 != null)
              Expanded(
                child: _buildComparisonView(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelectors() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTeamDropdown(_selectedTeam1, (team) => setState(() => _selectedTeam1 = team)),
        const Text('VS'),
        _buildTeamDropdown(_selectedTeam2, (team) => setState(() => _selectedTeam2 = team)),
      ],
    );
  }

  Widget _buildTeamDropdown(Team? selectedTeam, ValueChanged<Team?> onChanged) {
    return DropdownButton<Team>(
      value: selectedTeam,
      hint: const Text('Select Team'),
      items: _allTeams.map((team) {
        return DropdownMenuItem<Team>(
          value: team,
          child: Text(team.name),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildComparisonView() {
    // In a real app, you would fetch and display much more detailed comparison data.
    return ListView(
      children: [
        _buildComparisonRow('ELO Rating', _selectedTeam1!.eloRating.toString(), _selectedTeam2!.eloRating.toString()),
        _buildComparisonRow('Seasonal Points', _selectedTeam1!.seasonalPoints.toString(), _selectedTeam2!.seasonalPoints.toString()),
        _buildComparisonRow('Tier', _selectedTeam1!.tier.toString().split('.').last, _selectedTeam2!.tier.toString().split('.').last),
      ],
    );
  }

  Widget _buildComparisonRow(String title, String value1, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value1, style: const TextStyle(fontSize: 16)),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value2, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
