import 'package:esport_mgm/models/revenue_agreement.dart';
import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:esport_mgm/services/finance_service.dart';
import 'package:flutter/material.dart';

class RevenueAgreementScreen extends StatefulWidget {
  final Team team;

  const RevenueAgreementScreen({super.key, required this.team});

  @override
  State<RevenueAgreementScreen> createState() => _RevenueAgreementScreenState();
}

class _RevenueAgreementScreenState extends State<RevenueAgreementScreen> {
  late final FinanceService _financeService;
  final _formKey = GlobalKey<FormState>();
  double _orgPercentage = 30.0; // Default
  final Map<String, TextEditingController> _playerControllers = {};

  @override
  void initState() {
    super.initState();
    _financeService = FinanceService(DBService.instance.db);
    // Initialize controllers for each player
    for (final playerId in widget.team.players) {
      _playerControllers[playerId] = TextEditingController(text: '25.0'); // Default even split
    }
  }

  @override
  void dispose() {
    for (final controller in _playerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAgreement() async {
    if (!_formKey.currentState!.validate()) return;

    final playerPercentages = _playerControllers.map(
      (key, value) => MapEntry(key, double.tryParse(value.text) ?? 0.0),
    );

    // Basic validation
    final totalPlayerPct = playerPercentages.values.fold(0.0, (sum, item) => sum + item);
    if ((_orgPercentage + totalPlayerPct) > 100.1 || (_orgPercentage + totalPlayerPct) < 99.9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Percentages must add up to 100.')),
      );
      return;
    }

    final agreement = RevenueAgreement(
      teamId: widget.team.id.toHexString(),
      organizationPercentage: _orgPercentage,
      playerPercentages: playerPercentages,
    );

    try {
      await _financeService.saveAgreement(agreement);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revenue agreement saved successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save agreement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Revenue Agreement for ${widget.team.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Organization Percentage: ${_orgPercentage.toStringAsFixed(1)}%'),
              Slider(
                value: _orgPercentage,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${_orgPercentage.round()}%',
                onChanged: (double value) {
                  setState(() {
                    _orgPercentage = value;
                  });
                },
              ),
              const Divider(height: 32),
              const Text('Player Percentages', style: TextStyle(fontWeight: FontWeight.bold)),
              ...widget.team.players.map((playerId) {
                return TextFormField(
                  controller: _playerControllers[playerId],
                  decoration: InputDecoration(labelText: 'Player: $playerId'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                );
              }),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _saveAgreement, child: const Text('Save Agreement')),
            ],
          ),
        ),
      ),
    );
  }
}
