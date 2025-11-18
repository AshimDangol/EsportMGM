import 'package:esport_mgm/models/player_discipline.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:esport_mgm/services/player_discipline_service.dart';
import 'package:flutter/material.dart';

class PlayerDisciplineScreen extends StatefulWidget {
  final String playerId;

  const PlayerDisciplineScreen({super.key, required this.playerId});

  @override
  State<PlayerDisciplineScreen> createState() => _PlayerDisciplineScreenState();
}

class _PlayerDisciplineScreenState extends State<PlayerDisciplineScreen> {
  late final PlayerDisciplineService _disciplineService;
  PlayerDiscipline? _disciplineRecord;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _disciplineService = PlayerDisciplineService(DBService.instance.db);
    _loadDisciplineRecord();
  }

  Future<void> _loadDisciplineRecord() async {
    setState(() {
      _isLoading = true;
    });
    final record = await _disciplineService.getDisciplineRecord(widget.playerId);
    setState(() {
      _disciplineRecord = record;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discipline for ${widget.playerId}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDisciplineRecord,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  const Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  _buildHistoryList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    final status = _disciplineRecord?.currentStatus ?? PlayerStatus.active;
    final statusText = status.toString().split('.').last.toUpperCase();
    final color = status == PlayerStatus.banned
        ? Colors.red
        : status == PlayerStatus.suspended
            ? Colors.orange
            : Colors.green;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(statusText, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.bold)),
            if (_disciplineRecord?.suspensionEndDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Suspended until: ${_disciplineRecord!.suspensionEndDate!.toLocal()}'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // In a real app, you would get the adminId from your auth service
    const adminId = 'current_admin_user_id';

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.block),
          label: const Text('Ban'),
          onPressed: () => _showActionDialog(PlayerStatus.banned, adminId),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.timer_off),
          label: const Text('Suspend'),
          onPressed: () => _showActionDialog(PlayerStatus.suspended, adminId),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.gpp_good),
          label: const Text('Pardon'),
          onPressed: () => _showActionDialog(PlayerStatus.active, adminId),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    final history = _disciplineRecord?.history ?? [];
    if (history.isEmpty) {
      return const Center(child: Text('No disciplinary actions recorded.'));
    }

    // Show newest first
    final reversedHistory = history.reversed.toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reversedHistory.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final action = reversedHistory[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text('Action: ${action.status.toString().split('.').last.toUpperCase()}'),
          subtitle: Text('Reason: ${action.reason}\nBy: ${action.performedBy} on ${action.timestamp.toLocal()}'),
        );
      },
    );
  }

  void _showActionDialog(PlayerStatus status, String adminId) {
    final reasonController = TextEditingController();
    DateTime? suspensionDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${status.toString().split('.').last} Player'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
            if (status == PlayerStatus.suspended)
              TextButton(
                child: Text(suspensionDate == null
                    ? 'Select Suspension End Date'
                    : 'Ends: ${suspensionDate!.toLocal().toShortDateString()}'),
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      suspensionDate = pickedDate;
                    });
                  }
                },
              )
          ],
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;

              try {
                switch (status) {
                  case PlayerStatus.banned:
                    await _disciplineService.banPlayer(widget.playerId, reason, adminId);
                    break;
                  case PlayerStatus.suspended:
                    if (suspensionDate == null) return; // Basic validation
                    await _disciplineService.suspendPlayer(
                        widget.playerId, reason, adminId, suspensionDate!);
                    break;
                  case PlayerStatus.active:
                    await _disciplineService.pardonPlayer(widget.playerId, reason, adminId);
                    break;
                }
                Navigator.of(context).pop();
                _loadDisciplineRecord(); // Refresh the data
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to perform action: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

extension on DateTime {
  String toShortDateString() {
    return '$year-$month-$day';
  }
}
