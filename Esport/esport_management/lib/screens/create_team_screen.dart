import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateTeamScreen extends StatefulWidget {
  final User user;
  final String clanId;

  const CreateTeamScreen({super.key, required this.user, required this.clanId});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gameController = TextEditingController();
  Region _selectedRegion = Region.global;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _gameController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final team = Team(
        id: const Uuid().v4(),
        name: _nameController.text,
        game: _gameController.text,
        region: _selectedRegion,
        managerId: widget.user.id,
        clanId: widget.clanId,
      );
      await context.read<TeamService>().createTeam(team);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team Created!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create team: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Team'),
      ),
      body: Padding(
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
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _createTeam,
                  child: const Text('Create'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
