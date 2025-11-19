import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/tournament_details_screen.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinTournamentScreen extends StatefulWidget {
  final User user;
  const JoinTournamentScreen({super.key, required this.user});

  @override
  State<JoinTournamentScreen> createState() => _JoinTournamentScreenState();
}

class _JoinTournamentScreenState extends State<JoinTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tournamentService = TournamentService();
  final _joinCodeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _joinTournament() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tournament = await _tournamentService.getTournamentByJoinCode(_joinCodeController.text);
      if (tournament != null && mounted) {
        // Navigate to the tournament details screen upon success
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => TournamentDetailsScreen(tournamentId: tournament.id, user: widget.user),
        ));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid or expired join code.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join tournament: $e')),
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
        title: const Text('Join a Tournament'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _joinCodeController,
                decoration: const InputDecoration(labelText: 'Tournament Join Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a join code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _joinTournament,
                  child: const Text('Join'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
