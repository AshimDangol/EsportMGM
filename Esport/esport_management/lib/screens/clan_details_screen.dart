import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/create_team_screen.dart';
import 'package:esport_mgm/screens/user_profile_screen.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ClanDetailsScreen extends StatefulWidget {
  final Clan clan;
  final User user;

  const ClanDetailsScreen({super.key, required this.clan, required this.user});

  @override
  State<ClanDetailsScreen> createState() => _ClanDetailsScreenState();
}

class _ClanDetailsScreenState extends State<ClanDetailsScreen> {
  late Stream<Clan?> _clanStream;

  @override
  void initState() {
    super.initState();
    _clanStream = context.read<ClanService>().getClanStream(widget.clan.id);
  }

  Future<bool?> _showConfirmationDialog(
      {required String title, required String content}) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Confirm'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  void _showManagementDialog(BuildContext context, Clan clan, Player member) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        bool isOwner = clan.ownerId == widget.user.id;

        return Wrap(
          children: <Widget>[
            if (isOwner)
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Promote to Admin'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirmed = await _showConfirmationDialog(
                      title: 'Transfer Ownership',
                      content: 'Are you sure you want to make ${member.gamerTag} the new Admin? You will lose your admin privileges.');
                  if (confirmed == true) {
                    await context.read<ClanService>().promoteToAdmin(clan.id, member.userId);
                  }
                },
              ),
            if (isOwner)
              ListTile(
                leading: const Icon(Icons.shield),
                title: Text(clan.coAdminIds.contains(member.userId) ? 'Demote from Co-Admin' : 'Promote to Co-Admin'),
                onTap: () async {
                  Navigator.pop(ctx);
                  bool makeCoAdmin = !clan.coAdminIds.contains(member.userId);
                  await context.read<ClanService>().promoteToCoAdmin(clan.id, member.userId, makeCoAdmin);
                },
              ),
            if ((isOwner || clan.coAdminIds.contains(widget.user.id)) && clan.ownerId != member.userId)
              ListTile(
                leading: const Icon(Icons.remove_circle, color: Colors.red),
                title: const Text('Remove from Clan', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirmed = await _showConfirmationDialog(
                      title: 'Remove Member',
                      content: 'Are you sure you want to remove ${member.gamerTag} from the clan?');
                  if (confirmed == true) {
                    await context.read<ClanService>().removePlayerFromClan(clan.id, member.userId);
                  }
                },
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Clan?>(
        stream: _clanStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Clan not found.'));
          }
          final clan = snapshot.data!;
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(clan),
              _buildClanBody(clan),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(Clan clan) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
        title: Text(clan.name, style: const TextStyle(shadows: [Shadow(blurRadius: 10)])),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              clan.logoUrl ?? 'https://via.placeholder.com/400x200.png/222/fff?text=Clan+Logo', // Placeholder
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildClanBody(Clan clan) {
    bool isOwner = clan.ownerId == widget.user.id;
    bool isCoAdmin = clan.coAdminIds.contains(widget.user.id);

    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tag: ${clan.tag}', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Join Code: ${clan.joinCode}', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: clan.joinCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied Join Code to Clipboard')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isOwner)
          _buildPrivacySettings(clan),
        if ((isOwner || isCoAdmin) && clan.pendingMemberIds.isNotEmpty)
          _buildSectionTitle('Pending Join Requests (${clan.pendingMemberIds.length})'),
        if ((isOwner || isCoAdmin) && clan.pendingMemberIds.isNotEmpty)
          _buildJoinRequestsList(clan),
        _buildSectionTitle('Members (${clan.memberIds.length})'),
        _buildMembersList(clan),
        if (isOwner)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateTeamScreen(user: widget.user, clanId: clan.id))),
              icon: const Icon(Icons.add),
              label: const Text('Create New Team'),
            ),
          ),
      ]),
    );
  }

  Widget _buildPrivacySettings(Clan clan) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Clan Privacy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButton<ClanPrivacy>(
            value: clan.privacy,
            items: ClanPrivacy.values.map((privacy) {
              return DropdownMenuItem<ClanPrivacy>(
                value: privacy,
                child: Text(privacy.name.capitalize()),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                context.read<ClanService>().updateClanPrivacy(clan.id, newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildJoinRequestsList(Clan clan) {
    final playerService = context.read<PlayerService>();

    return FutureBuilder<List<Player>>(
      future: playerService.getPlayersByIds(clan.pendingMemberIds),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final requesters = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requesters.length,
          itemBuilder: (context, index) {
            final requester = requesters[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                title: Text(requester.gamerTag),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => context.read<ClanService>().approveJoinRequest(clan.id, requester.userId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => context.read<ClanService>().rejectJoinRequest(clan.id, requester.userId),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMembersList(Clan clan) {
    final playerService = context.read<PlayerService>();
    bool canManage = clan.ownerId == widget.user.id || clan.coAdminIds.contains(widget.user.id);

    return FutureBuilder<List<Player>>(
      future: playerService.getPlayersByIds(clan.memberIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No members found.'));
        }
        final members = snapshot.data!;

        members.sort((a, b) {
          if (a.userId == clan.ownerId) return -1;
          if (b.userId == clan.ownerId) return 1;
          if (clan.coAdminIds.contains(a.userId)) return -1;
          if (clan.coAdminIds.contains(b.userId)) return 1;
          return a.gamerTag.compareTo(b.gamerTag);
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            String subtitle = 'Member';
            IconData icon = Icons.person;
            Color? iconColor;
            if (member.userId == clan.ownerId) {
              subtitle = 'Admin';
              icon = Icons.star;
              iconColor = Colors.amber;
            } else if (clan.coAdminIds.contains(member.userId)) {
              subtitle = 'Co-Admin';
              icon = Icons.shield;
              iconColor = Colors.blue;
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(child: Icon(icon, color: iconColor)),
                title: Text(member.gamerTag),
                subtitle: Text(subtitle),
                onTap: member.userId != widget.user.id
                    ? () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            userId: member.userId,
                            currentUser: widget.user,
                          ),
                        ))
                    : null,
                trailing: canManage && member.userId != widget.user.id
                    ? IconButton(
                        tooltip: 'Manage Member',
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showManagementDialog(context, clan, member),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
