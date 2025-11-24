import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PublicClanProfileScreen extends StatefulWidget {
  final Clan clan;
  final User currentUser;

  const PublicClanProfileScreen({super.key, required this.clan, required this.currentUser});

  @override
  State<PublicClanProfileScreen> createState() => _PublicClanProfileScreenState();
}

class _PublicClanProfileScreenState extends State<PublicClanProfileScreen> {
  bool _isMember = false;
  bool _requestSent = false;

  @override
  void initState() {
    super.initState();
    _isMember = widget.clan.memberIds.contains(widget.currentUser.id);
    _requestSent = widget.clan.pendingMemberIds.contains(widget.currentUser.id);
  }

  Future<void> _handleJoinRequest() async {
    final clanService = context.read<ClanService>();
    switch (widget.clan.privacy) {
      case ClanPrivacy.public:
        await clanService.joinClan(widget.clan.id, widget.currentUser.id);
        setState(() {
          _isMember = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined clan!')),
        );
        break;
      case ClanPrivacy.private:
        await clanService.requestToJoinClan(widget.clan.id, widget.currentUser.id);
        setState(() {
          _requestSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your request to join has been sent.')),
        );
        break;
      case ClanPrivacy.closed:
        // Button is disabled, so this should not be callable.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clan.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: widget.clan.logoUrl != null ? NetworkImage(widget.clan.logoUrl!) : null,
              child: widget.clan.logoUrl == null ? const Icon(Icons.shield, size: 60) : null,
            ),
            const SizedBox(height: 16),
            Text(widget.clan.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Join Code: ${widget.clan.joinCode}', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.clan.joinCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied Join Code to Clipboard')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('${widget.clan.memberIds.length} Members', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 32),
            _buildOwnerCard(),
            const SizedBox(height: 32),
            if (!_isMember) 
              _buildJoinButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    if (widget.clan.privacy == ClanPrivacy.closed) {
      return const ElevatedButton(onPressed: null, child: Text('Closed'));
    }
    if (_requestSent) {
      return const ElevatedButton(onPressed: null, child: Text('Request Sent'));
    }
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
      onPressed: _handleJoinRequest,
      icon: const Icon(Icons.group_add),
      label: Text(widget.clan.privacy == ClanPrivacy.private ? 'Request to Join' : 'Join Clan'),
    );
  }

  Widget _buildOwnerCard() {
    final playerService = context.read<PlayerService>();
    return Column(
      children: [
        Text('Clan Owner', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        FutureBuilder<Player?>(
          future: playerService.getPlayerByUserId(widget.clan.ownerId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Card(child: ListTile(title: Text('Loading owner...')));
            }
            final owner = snapshot.data;
            return Card(
              elevation: 4,
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(owner?.gamerTag ?? 'Unknown Owner'),
                subtitle: const Text('Admin'),
              ),
            );
          },
        ),
      ],
    );
  }
}
