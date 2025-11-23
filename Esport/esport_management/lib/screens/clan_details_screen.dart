import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/player_role.dart';
import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/create_team_screen.dart';
import 'package:esport_mgm/screens/tournament_registration_screen.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClanDetailsScreen extends StatefulWidget {
  final Clan clan;
  final User user;

  const ClanDetailsScreen({super.key, required this.clan, required this.user});

  @override
  State<ClanDetailsScreen> createState() => _ClanDetailsScreenState();
}

class _ClanDetailsScreenState extends State<ClanDetailsScreen> {
  late Future<List<Tournament>> _tournamentsFuture;
  late Future<List<User>> _membersFuture;
  late Future<List<Team>> _teamsFuture;

  bool get _isOwner => widget.clan.ownerId == widget.user.id;
  bool get _isMember => widget.clan.memberIds.contains(widget.user.id);

  @override
  void initState() {
    super.initState();
    _tournamentsFuture = context.read<TournamentService>().getTournamentsForClan(widget.clan.id);
    _membersFuture = context.read<FirestoreService>().getUsers(widget.clan.memberIds);
    _teamsFuture = context.read<TeamService>().getTeamsForClan(widget.clan.id);
  }

  void _refresh() {
    setState(() {
      _tournamentsFuture = context.read<TournamentService>().getTournamentsForClan(widget.clan.id);
      _membersFuture = context.read<FirestoreService>().getUsers(widget.clan.memberIds);
      _teamsFuture = context.read<TeamService>().getTeamsForClan(widget.clan.id);
    });
  }

  Future<void> _joinClan() async {
    await context.read<ClanService>().joinClan(widget.clan.id, widget.user.id);
    _refresh();
  }

  Future<void> _leaveClan() async {
    await context.read<ClanService>().leaveClan(widget.clan.id, widget.user.id);
    _refresh();
  }

  Future<void> _registerForTournament() async {
    final selectedTournament = await Navigator.push<Tournament>(
      context,
      MaterialPageRoute(
        builder: (context) => const TournamentRegistrationScreen(),
      ),
    );

    if (selectedTournament != null) {
      await context.read<TournamentService>().registerClan(selectedTournament.id, widget.clan.id);
      _refresh();
    }
  }

  Future<void> _navigateToCreateTeamScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateTeamScreen(user: widget.user, clanId: widget.clan.id),
      ),
    );

    if (result == true) {
      _refresh();
    }
  }

  Future<void> _showRoleDialog(User member) async {
    final selectedRole = await showDialog<PlayerRole>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Role'),
          children: PlayerRole.values.map((role) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, role),
              child: Text(role.name),
            );
          }).toList(),
        );
      },
    );

    if (selectedRole != null) {
      await context.read<ClanService>().updateClanRole(widget.clan.id, member.id, selectedRole);
      _refresh();
    }
  }

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
              _buildSectionTitle('Teams'),
              _buildTeamsList(),
              if (_isOwner)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: _navigateToCreateTeamScreen,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Team'),
                  ),
                ),
              const SizedBox(height: 24),
              _buildSectionTitle('Tournaments'),
              _buildTournamentsList(),
              if (_isOwner)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                      onPressed: _registerForTournament,
                      child: const Text('Register for Tournament')),
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
        child: ElevatedButton(onPressed: _joinClan, child: const Text('Join Clan')),
      );
    }
    if (_isMember && !_isOwner) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(onPressed: _leaveClan, child: const Text('Leave Clan')),
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
                      onPressed: () => _showRoleDialog(member),
                    )
                  : null,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTeamsList() {
    return FutureBuilder<List<Team>>(
        future: _teamsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not fetch teams.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No teams found.'));
          }

          final teams = snapshot.data!;

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return Card(
                child: ListTile(
                  title: Text(team.name),
                  subtitle: Text(team.game),
                ),
              );
            },
          );
        });
  }

  Widget _buildTournamentsList() {
    return FutureBuilder<List<Tournament>>(
      future: _tournamentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tournaments found.'));
        }

        final tournaments = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tournaments.length,
          itemBuilder: (context, index) {
            final tournament = tournaments[index];
            return Card(
              child: ListTile(
                title: Text(tournament.name),
                subtitle: Text(tournament.game),
              ),
            );
          },
        );
      },
    );
  }
}
