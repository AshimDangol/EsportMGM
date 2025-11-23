import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/player_stats.dart';
import 'package:flutter/material.dart';

class PlayerStatInputRow extends StatefulWidget {
  final Player player;
  final Function(PlayerStats) onStatsChanged;

  const PlayerStatInputRow({super.key, required this.player, required this.onStatsChanged});

  @override
  State<PlayerStatInputRow> createState() => _PlayerStatInputRowState();
}

class _PlayerStatInputRowState extends State<PlayerStatInputRow> {
  final _killsController = TextEditingController();
  final _deathsController = TextEditingController();
  final _assistsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _killsController.addListener(_onChanged);
    _deathsController.addListener(_onChanged);
    _assistsController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _killsController.dispose();
    _deathsController.dispose();
    _assistsController.dispose();
    super.dispose();
  }

  void _onChanged() {
    final kills = int.tryParse(_killsController.text) ?? 0;
    final deaths = int.tryParse(_deathsController.text) ?? 0;
    final assists = int.tryParse(_assistsController.text) ?? 0;
    widget.onStatsChanged(PlayerStats(id: widget.player.id, kills: kills, deaths: deaths, assists: assists));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.player.gamerTag, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _killsController,
                  decoration: const InputDecoration(labelText: 'Kills'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _deathsController,
                  decoration: const InputDecoration(labelText: 'Deaths'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _assistsController,
                  decoration: const InputDecoration(labelText: 'Assists'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
