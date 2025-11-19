import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/player_role.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';

class ClanDetailsScreen extends StatefulWidget {
  final Clan clan;
  final User user;

  const ClanDetailsScreen({super.key, required this.clan, required this.user});

  @override
  State<ClanDetailsScreen> createState() => _ClanDetailsScreenState();
}

class _ClanDetailsScreenState extends State<ClanDetailsScreen> {
  final ClanService _clanService = ClanService();
  final TournamentService _tournamentService = TournamentService();
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Tournament>> _tournamentsFuture;
  late Future<List<User>> _membersFuture;

  bool get _isOwner => widget.clan.ownerId == widget.user.id;
  bool get _isMember => widget.clan.memberIds.contains(widget.user.id);

  @override
  void initState() {
    super.initState();
    _tournamentsFuture = _tournamentService.getTournamentsForClan(widget.clan.id);
    _membersFuture = _firestoreService.getUsers(widget.clan.memberIds);
  }

  void _refresh() {
    setState(() {
      _tournamentsFuture = _tournamentService.getTournamentsForClan(widget.clan.id);
      _membersFuture = _firestoreService.getUsers(widget.clan.memberIds);
    });
  }

  // ... (rest of the methods from before)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.clan.name),
              background: _buildBanner(), // Placeholder for banner
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildJoinLeaveButtons(),
              _buildSectionTitle('Clan Tag'),
              Text(widget.clan.tag, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              _buildSectionTitle('Members'),
              _buildMembersList(),
              const SizedBox(height: 24),
              _buildSectionTitle('Team Stats'),
              _buildStatsGraph(), // Placeholder for graph
              const SizedBox(height: 24),
              _buildSectionTitle('Tournaments'),
              _buildTournamentsList(),
               if (_isOwner)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(onPressed: (){/* register for tournament*/}, child: const Text('Register for Tournament')),
                )
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      color: Colors.grey[800], // Placeholder color
      child: const Center(
        child: Icon(Icons.shield, size: 80, color: Colors.white70),
      ),
    );
  }
  
  Widget _buildJoinLeaveButtons() {
    if (!_isMember) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(onPressed: (){/* join clan*/}, child: const Text('Join Clan')),
      );
    }
    if (_isMember && !_isOwner) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(onPressed: (){/* leave clan*/}, child: const Text('Leave Clan')),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMembersList() {
     return FutureBuilder<List<User>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No members found.'));
          }
          final members = snapshot.data!;
          return Column(
            children: members.map((member) {
              final role = widget.clan.roles[member.id];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(member.email),
                subtitle: Text(role?.name ?? 'No role assigned'),
                trailing: _isOwner
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {/* show role dialog*/},
                      )
                    : null,
              );
            }).toList(),
          );
        },
      );
  }

  Widget _buildStatsGraph() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: Text('Stats Graph Placeholder')),
    );
  }

  Widget _buildTournamentsList() {
    return FutureBuilder<List<Tournament>>(
      future: _tournamentsFuture,
      builder: (context, snapshot) {
        // ... (implementation is the same as before)
        return const Center(child: Text('Tournament list placeholder'));
      },
    );
  }
}
