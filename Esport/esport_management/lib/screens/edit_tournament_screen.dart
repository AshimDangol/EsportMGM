import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class EditTournamentScreen extends StatefulWidget {
  final User user;
  final Tournament? tournament;

  const EditTournamentScreen({super.key, required this.user, this.tournament});

  @override
  State<EditTournamentScreen> createState() => _EditTournamentScreenState();
}

class _EditTournamentScreenState extends State<EditTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TournamentService _tournamentService = TournamentService();

  // Form fields
  late String _name;
  late String _game;
  late String _description;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _venue;
  double? _prizePool;
  TournamentFormat _format = TournamentFormat.singleElimination;
  String? _rules;

  bool get _isEditing => widget.tournament != null;

  @override
  void initState() {
    super.initState();
    _name = widget.tournament?.name ?? '';
    _game = widget.tournament?.game ?? '';
    _description = widget.tournament?.description ?? '';
    _startDate = widget.tournament?.startDate;
    _endDate = widget.tournament?.endDate;
    _venue = widget.tournament?.venue;
    _prizePool = widget.tournament?.prizePool;
    _format = widget.tournament?.format ?? TournamentFormat.singleElimination;
    _rules = widget.tournament?.rules;
  }

  String _generateJoinCode() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> _pickDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a start date.')),
        );
        return;
      }

      final tournament = Tournament(
        id: _isEditing ? widget.tournament!.id : const Uuid().v4(),
        name: _name,
        game: _game,
        description: _description,
        startDate: _startDate!,
        endDate: _endDate,
        venue: _venue,
        prizePool: _prizePool ?? 0.0,
        prizeDistribution: _isEditing ? widget.tournament!.prizeDistribution : [],
        registeredClanIds: _isEditing ? widget.tournament!.registeredClanIds : [],
        checkedInClanIds: _isEditing ? widget.tournament!.checkedInClanIds : [],
        format: _format,
        rules: _rules ?? '',
        matches: _isEditing ? widget.tournament!.matches : [],
        seeding: _isEditing ? widget.tournament!.seeding : {},
        adminId: _isEditing ? widget.tournament!.adminId : widget.user.id,
        joinCode: _isEditing ? widget.tournament!.joinCode : _generateJoinCode(),
      );

      if (_isEditing) {
        await _tournamentService.updateTournament(tournament);
      } else {
        await _tournamentService.addTournament(tournament);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Tournament' : 'Create Tournament'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Tournament Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _game,
                decoration: const InputDecoration(labelText: 'Game'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a game' : null,
                onSaved: (value) => _game = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Start: ${_startDate != null ? DateFormat.yMMMd().format(_startDate!) : 'Not set'}'),
                  ElevatedButton(onPressed: () => _pickDate(true), child: const Text('Select')),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('End:   ${_endDate != null ? DateFormat.yMMMd().format(_endDate!) : 'Not set'}'),
                  ElevatedButton(onPressed: () => _pickDate(false), child: const Text('Select')),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _venue,
                decoration: const InputDecoration(labelText: 'Venue'),
                onSaved: (value) => _venue = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _prizePool?.toString(),
                decoration: const InputDecoration(labelText: 'Prize Pool'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _prizePool = double.tryParse(value ?? ''),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TournamentFormat>(
                value: _format,
                decoration: const InputDecoration(labelText: 'Format'),
                items: TournamentFormat.values.map((TournamentFormat format) {
                  return DropdownMenuItem<TournamentFormat>(
                    value: format,
                    child: Text(format.name),
                  );
                }).toList(),
                onChanged: (TournamentFormat? newValue) {
                  setState(() {
                    _format = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _rules,
                decoration: const InputDecoration(labelText: 'Rules'),
                maxLines: 5,
                onSaved: (value) => _rules = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Update Tournament' : 'Create Tournament'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
