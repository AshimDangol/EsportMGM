import 'package:esport_mgm/models/game_event.dart';
import 'package:esport_mgm/models/match.dart';
import 'package:esport_mgm/models/match_integrity_audit.dart';
import 'package:esport_mgm/screens/match_integrity_review_screen.dart';
import 'package:esport_mgm/services/game_event_service.dart';
import 'package:esport_mgm/services/match_integrity_service.dart';
import 'package:esport_mgm/services/ranking_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MatchDetailsScreen extends StatefulWidget {
  final Match match;

  const MatchDetailsScreen({super.key, required this.match});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MatchIntegrityService _integrityService;
  late GameEventService _eventService;
  Future<List<MatchIntegrityAudit>>? _auditsFuture;
  Future<List<GameEvent>>? _eventsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _integrityService = MatchIntegrityService();
    _eventService = GameEventService();
    _loadAudits();
    _loadEvents();
  }

  Future<void> _loadAudits() async {
    setState(() {
      _auditsFuture = _integrityService.getAuditsForMatch(widget.match.id.toHexString());
    });
  }

  Future<void> _loadEvents() async {
    setState(() {
      _eventsFuture = _eventService.getEventsForMatch(widget.match.id.toHexString());
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
        title: Text('Match ${widget.match.matchNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.gavel),
            tooltip: 'Conduct Integrity Review',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchIntegrityReviewScreen(matchId: widget.match.id.toHexString()),
                ),
              );
              _loadAudits();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Score'),
            Tab(text: 'Event Log'),
            Tab(text: 'Integrity Audits'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ScoreEditor(match: widget.match),
          _buildEventLog(),
          _buildAuditHistory(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _showAddEventDialog,
              child: const Icon(Icons.add),
              tooltip: 'Add Manual Event',
            )
          : null,
    );
  }

  Widget _buildEventLog() {
    return FutureBuilder<List<GameEvent>>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading events: ${snapshot.error}'));
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return const Center(child: Text('No game events recorded yet.'));
        }
        return RefreshIndicator(
          onRefresh: _loadEvents,
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: const Icon(Icons.videogame_asset),
                title: Text('${event.eventType.toString().split('.').last} by ${event.playerId}'),
                subtitle: Text('Data: ${event.eventData.toString()}\n${event.timestamp.toLocal()}'),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddEventDialog() {
    final players = [widget.match.team1Id, widget.match.team2Id].where((id) => id != null).toList();
    if (players.isEmpty) return;

    final randomPlayer = players[Random().nextInt(players.length)]!;
    final event = GameEvent(
      matchId: widget.match.id.toHexString(),
      playerId: randomPlayer,
      eventType: GameEventType.kill,
      eventData: {'weapon': 'ManualTest', 'headshot': Random().nextBool()},
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Manual Event'),
        content: Text('Add a test KILL event for player $randomPlayer?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
          TextButton(
            child: const Text('Add'),
            onPressed: () async {
              await _eventService.recordEvent(event);
              Navigator.of(context).pop();
              _loadEvents();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuditHistory() {
    return FutureBuilder<List<MatchIntegrityAudit>>(
      future: _auditsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading audits: ${snapshot.error}'));
        }
        final audits = snapshot.data ?? [];
        if (audits.isEmpty) {
          return const Center(child: Text('No integrity audits for this match.'));
        }
        return RefreshIndicator(
          onRefresh: _loadAudits,
          child: ListView.builder(
            itemCount: audits.length,
            itemBuilder: (context, index) {
              final audit = audits[index];
              return ListTile(
                title: Text('Review by ${audit.reviewerId} on ${audit.timestamp.toLocal()}'),
                subtitle: Text('Action: ${audit.actionTaken.toString().split('.').last}\nNotes: ${audit.notes}'),
              );
            },
          ),
        );
      },
    );
  }
}

class ScoreEditor extends StatefulWidget {
  final Match match;

  const ScoreEditor({super.key, required this.match});

  @override
  _ScoreEditorState createState() => _ScoreEditorState();
}

class _ScoreEditorState extends State<ScoreEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _team1ScoreController;
  late final TextEditingController _team2ScoreController;
  late final TournamentService _tournamentService;
  late final RankingService _rankingService;

  @override
  void initState() {
    super.initState();
    _team1ScoreController = TextEditingController(text: widget.match.team1Score.toString());
    _team2ScoreController = TextEditingController(text: widget.match.team2Score.toString());
    _tournamentService = TournamentService();
    _rankingService = RankingService();
  }

  @override
  void dispose() {
    _team1ScoreController.dispose();
    _team2ScoreController.dispose();
    super.dispose();
  }

  Future<void> _updateScore() async {
    if (!_formKey.currentState!.validate()) return;

    final team1Score = int.parse(_team1ScoreController.text);
    final team2Score = int.parse(_team2ScoreController.text);

    try {
      // First, update the match score in the tournament
      await _tournamentService.updateMatchScore(
        widget.match.id.toHexString(), // This seems incorrect, review tournament_service
        widget.match.id.toHexString(),
        team1Score,
        team2Score,
      );

      // Then, update the rankings based on the result
      final updatedMatch = widget.match.copyWith(
        team1Score: team1Score,
        team2Score: team2Score,
        winnerId: team1Score > team2Score ? widget.match.team1Id : widget.match.team2Id,
        status: MatchStatus.completed,
      );
      await _rankingService.updatePostMatchStats(updatedMatch);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Score updated successfully!')));
      Navigator.pop(context, true); // Pop with a result to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update score: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${widget.match.team1Id ?? 'TBD'} vs ${widget.match.team2Id ?? 'TBD'}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            TextFormField(
              controller: _team1ScoreController,
              decoration: InputDecoration(labelText: 'Score - ${widget.match.team1Id ?? 'Team 1'}'),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _team2ScoreController,
              decoration: InputDecoration(labelText: 'Score - ${widget.match.team2Id ?? 'Team 2'}'),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateScore,
              child: const Text('Save Final Score'),
            ),
          ],
        ),
      ),
    );
  }
}
