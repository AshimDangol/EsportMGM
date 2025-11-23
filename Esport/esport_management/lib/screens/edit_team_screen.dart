import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/player_selection_screen.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditTeamScreen extends StatefulWidget {
  final User user;
  final String clanId;
  final String? teamId;

  const EditTeamScreen({super.key, required this.user, required this.clanId, this.teamId});

  @override
  State<EditTeamScreen> createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends State<EditTeamScreen> {
  final _formKey = GlobalKey<FormState>();

  late Future<Team?> _teamFuture;
  Team? _team;

  final _nameController = TextEditingController();
  final _gameController = TextEditingController();
  Region _selectedRegion = Region.global;

  List<Player> _selectedPlayers = [];

  bool get _isEditing => widget.teamId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _teamFuture = context.read<TeamService>().getTeamById(widget.teamId!);
      _teamFuture.then((team) {
        if (team != null) {
          _team = team;
          _nameController.text = team.name;
          _gameController.text = team.game;
          _selectedRegion = team.region;
          context.read<PlayerService>().getPlayersByIds(team.players).then((players) {
            setState(() {
              _selectedPlayers = players;
            });
          });
        }
      });
    } else {
      _teamFuture = Future.value(null);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final teamService = context.read<TeamService>();

      final team = Team(
        id: _isEditing ? widget.teamId! : UniqueKey().toString(),
        name: _nameController.text,
        game: _gameController.text,
        region: _selectedRegion,
        players: _selectedPlayers.map((p) => p.id).toList(),
        managerId: widget.user.id,
        clanId: _isEditing ? _team!.clanId : widget.clanId,
      );

      if (_isEditing) {
        await teamService.updateTeam(team);
      } else {
        await teamService.createTeam(team);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Team' : 'Create Team'),
      ),
      body: FutureBuilder<Team?>(
        future: _teamFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _isEditing) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Team Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a team name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _gameController,
                    decoration: const InputDecoration(labelText: 'Game'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a game';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Region>(
                    value: _selectedRegion,
                    decoration: const InputDecoration(labelText: 'Region'),
                    items: Region.values.map((Region region) {
                      return DropdownMenuItem<Region>(
                        value: region,
                        child: Text(region.name),
                      );
                    }).toList(),
                    onChanged: (Region? newValue) {
                      setState(() {
                        _selectedRegion = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlayerSelectionScreen(user: widget.user),
                        ),
                      );
                      if (result != null && result is List<Player>) {
                        setState(() {
                          _selectedPlayers = result;
                        });
                      }
                    },
                    child: const Text('Select Players'),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedPlayers.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _selectedPlayers.length,
                        itemBuilder: (context, index) {
                          final player = _selectedPlayers[index];
                          return ListTile(
                            title: Text(player.gamerTag),
                            subtitle: Text(player.realName ?? ''),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isEditing ? 'Update Team' : 'Create Team'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
