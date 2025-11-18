import 'package:esport_mgm/models/player_contract.dart';
import 'package:esport_mgm/services/player_contract_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPlayerScreen extends StatefulWidget {
  final String teamId;
  const AddPlayerScreen({super.key, required this.teamId});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contractService = PlayerContractService();

  final _playerIdController = TextEditingController();
  final _salaryController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Player to Team')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _playerIdController,
                decoration: const InputDecoration(labelText: 'Player ID (User ID)'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a player ID' : null,
              ),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: 'Salary (Optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        "Start Date: ${DateFormat.yMd().format(_startDate)}"),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: const Text('Select'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        "End Date: ${DateFormat.yMd().format(_endDate)}"),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: const Text('Select'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addPlayer,
                child: const Text('Add Player'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addPlayer() async {
    if (_formKey.currentState!.validate()) {
      final contract = PlayerContract(
        playerId: _playerIdController.text,
        teamId: widget.teamId,
        startDate: _startDate,
        endDate: _endDate,
        salary: double.tryParse(_salaryController.text),
      );

      try {
        await _contractService.createContract(contract);
        if (mounted) {
          Navigator.pop(context, true); // Signal success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to add player: $e')));
        }
      }
    }
  }
}
