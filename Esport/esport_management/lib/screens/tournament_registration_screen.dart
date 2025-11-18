import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:flutter/material.dart';

class TournamentRegistrationScreen extends StatefulWidget {
  final Tournament tournament;
  const TournamentRegistrationScreen({super.key, required this.tournament});

  @override
  State<TournamentRegistrationScreen> createState() =>
      _TournamentRegistrationScreenState();
}

class _TournamentRegistrationScreenState
    extends State<TournamentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _player1NameController = TextEditingController();
  final _player2NameController = TextEditingController();
  final _emailController = TextEditingController();

  late TeamService _teamService;

  @override
  void initState() {
    super.initState();
    // In a real app, you'd get this from a dependency injector
    _teamService = TeamService(DBService.instance.db);
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _player1NameController.dispose();
    _player2NameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final team = Team(
        name: _teamNameController.text,
        players: [
          _player1NameController.text,
          _player2NameController.text,
        ],
        tournamentId: widget.tournament.id.toHexString(),
      );

      try {
        await _teamService.addTeam(team);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register for ${widget.tournament.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _teamNameController,
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
                controller: _player1NameController,
                decoration: const InputDecoration(labelText: 'Player 1 Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a player name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _player2NameController,
                decoration: const InputDecoration(labelText: 'Player 2 Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a player name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Contact Email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
