import 'package:collection/collection.dart';
import 'package:esport_mgm/models/broadcast_schedule.dart';
import 'package:esport_mgm/models/match.dart';
import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/match_details_screen.dart';
import 'package:esport_mgm/screens/revenue_agreement_screen.dart';
import 'package:esport_mgm/screens/tournament_registration_screen.dart';
import 'package:esport_mgm/services/broadcast_service.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:esport_mgm/services/finance_service.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';

class EditTournamentScreen extends StatefulWidget {
  final User user;
  final Tournament? tournament;

  const EditTournamentScreen({super.key, required this.user, this.tournament});

  @override
  State<EditTournamentScreen> createState() => _EditTournamentScreenState();
}

class _EditTournamentScreenState extends State<EditTournamentScreen> with SingleTickerProviderStateMixin {
  bool get isEditing => widget.tournament != null;
  Tournament? _currentTournament;
  late TeamService _teamService;
  late FinanceService _financeService;
  late BroadcastService _broadcastService;
  late TabController _tabController;
  Future<List<Team>>? _teamsFuture;
  Future<List<BroadcastScheduleItem>>? _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _currentTournament = widget.tournament;
    _teamService = TeamService(DBService.instance.db);
    _financeService = FinanceService(DBService.instance.db);
    _broadcastService = BroadcastService(DBService.instance.db);
    _tabController = TabController(length: 4, vsync: this);

    if (isEditing) {
      _loadTeams();
      _loadSchedule();
    }
  }

  void _loadTeams() {
    setState(() {
      _teamsFuture = _teamService.getTeamsForTournament(_currentTournament!.id.toHexString());
    });
  }

  void _loadSchedule() {
    setState(() {
      _scheduleFuture = _broadcastService.getScheduleForTournament(_currentTournament!.id.toHexString());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Tournament' : 'Create Tournament'),
        actions: [/* ... */],
        bottom: isEditing
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Bracket'),
                  Tab(text: 'Teams'),
                  Tab(text: 'Finance'),
                  Tab(text: 'Broadcast'),
                ],
              )
            : null,
      ),
      body: isEditing
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildBracketView(),
                _buildRegisteredTeamsView(),
                _buildFinanceView(),
                _buildBroadcastScheduleView(),
              ],
            )
          : _buildCreateView(),
      floatingActionButton: isEditing && _tabController.index == 3
          ? FloatingActionButton(
              onPressed: () => _showScheduleItemDialog(),
              child: const Icon(Icons.add),
              tooltip: 'Add Schedule Item',
            )
          : null,
    );
  }

  Widget _buildBroadcastScheduleView() {
    return FutureBuilder<List<BroadcastScheduleItem>>(
      future: _scheduleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final scheduleItems = snapshot.data ?? [];
        if (scheduleItems.isEmpty) {
          return const Center(child: Text('No broadcast schedule yet.'));
        }
        return RefreshIndicator(
          onRefresh: _loadSchedule,
          child: ListView.builder(
            itemCount: scheduleItems.length,
            itemBuilder: (context, index) {
              final item = scheduleItems[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text(
                    '${item.startTime.toLocal()} - ${item.endTime.toLocal()}\nNotes: ${item.notes ?? 'N/A'}'),
                isThreeLine: true,
                onTap: () => _showScheduleItemDialog(existingItem: item),
              );
            },
          ),
        );
      },
    );
  }

  void _showScheduleItemDialog({BroadcastScheduleItem? existingItem}) {
    // This would be a more complex form in a real app
    final titleController = TextEditingController(text: existingItem?.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingItem == null ? 'Add Schedule Item' : 'Edit Schedule Item'),
        content: TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              final title = titleController.text;
              if (title.isEmpty) return;

              final newItem = BroadcastScheduleItem(
                tournamentId: _currentTournament!.id.toHexString(),
                title: title,
                startTime: DateTime.now(), // Placeholder
                endTime: DateTime.now().add(const Duration(hours: 1)), // Placeholder
              );

              if (existingItem == null) {
                await _broadcastService.addScheduleItem(newItem);
              } else {
                // This is a simplified update. A real implementation would copy properties.
                await _broadcastService.updateScheduleItem(newItem);
              }
              Navigator.of(context).pop();
              _loadSchedule();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredTeamsView() { /* ... */ }
  Widget _buildCreateView() { /* ... */ }
  Widget _buildFinanceView() { /* ... */ }
  Future<void> _showPrizeDistributionDialog() async { /* ... */ }
  Widget _buildBracketView() { /* ... */ }
  void _navigateToMatchDetails(Match match) { /* ... */ }
}
