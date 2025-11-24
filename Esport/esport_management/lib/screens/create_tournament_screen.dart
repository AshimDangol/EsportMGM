import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tournamentService = TournamentService();

  final _nameController = TextEditingController();
  final _gameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prizePoolController = TextEditingController();
  final _rulesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TournamentFormat _selectedFormat = TournamentFormat.singleElimination;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _gameController.dispose();
    _descriptionController.dispose();
    _prizePoolController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createTournament() async {
    final user = context.read<User?>();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text;
      final game = _gameController.text;
      final description = _descriptionController.text;
      final prizePool = double.tryParse(_prizePoolController.text) ?? 0.0;
      final rules = _rulesController.text;

      final newTournament = Tournament(
        id: const Uuid().v4(),
        name: name,
        game: game,
        startDate: _selectedDate,
        description: description,
        prizePool: prizePool,
        format: _selectedFormat,
        rules: rules,
        adminId: user!.id,
        joinCode: (const Uuid().v4()).substring(0, 6).toUpperCase(),
      );

      await _tournamentService.addTournament(newTournament);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tournament Created!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create tournament: $e')),
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
        title: const Text('Create Tournament'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tournament Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
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
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rulesController,
                  decoration: const InputDecoration(labelText: 'Rules'),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prizePoolController,
                  decoration: const InputDecoration(labelText: 'Prize Pool'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TournamentFormat>(
                  value: _selectedFormat,
                  decoration: const InputDecoration(labelText: 'Format'),
                  items: TournamentFormat.values.map((TournamentFormat format) {
                    return DropdownMenuItem<TournamentFormat>(
                      value: format,
                      child: Text(format.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (TournamentFormat? newValue) {
                    setState(() {
                      if (newValue != null) {
                        _selectedFormat = newValue;
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Date: ${DateFormat.yMd().format(_selectedDate)}",
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _createTournament,
                    child: const Text('Create'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
