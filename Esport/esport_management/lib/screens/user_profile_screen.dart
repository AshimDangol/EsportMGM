import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/friend_service.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:esport_mgm/screens/chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final User currentUser;
  const UserProfileScreen({super.key, required this.userId, required this.currentUser});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final playerService = context.read<PlayerService>();
    final friendService = context.read<FriendService>();
    final clanService = context.read<ClanService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: StreamBuilder<User?>(
        stream: firestoreService.getUserStream(widget.userId),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = userSnapshot.data!;

          return FutureBuilder<Player?>(
            future: playerService.getPlayerByUserId(user.id),
            builder: (context, playerSnapshot) {
              final player = playerSnapshot.data;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                      child: user.photoUrl == null ? const Icon(Icons.person, size: 60) : null,
                    ),
                    const SizedBox(height: 16),
                    Text(player?.gamerTag ?? user.email, style: Theme.of(context).textTheme.headlineSmall),
                    if (player?.realName != null) Text(player!.realName!, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('ID: ${user.id}', style: Theme.of(context).textTheme.bodySmall),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 14),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: user.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User ID Copied to Clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildActionButtons(user, player, friendService, clanService),
                    const Divider(height: 32),
                    if (player != null) _buildPlayerInfo(player),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(User user, Player? player, FriendService friendService, ClanService clanService) {
    final isFriend = widget.currentUser.friendIds.contains(user.id);

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: [
        if (isFriend)
          ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat'),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(currentUser: widget.currentUser, otherUser: user),
              ));
            },
          )
        else if (widget.currentUser.id != user.id)
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text('Add Friend'),
            onPressed: () async {
              await friendService.addFriend(widget.currentUser.id, user.id);
            },
          ),

        if (player != null && player.clanId == null)
          ElevatedButton.icon(
            icon: const Icon(Icons.group_add_outlined),
            label: const Text('Invite to Clan'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invitation sent to ${player.gamerTag}')),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPlayerInfo(Player player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (player.favoriteGames.isNotEmpty)
          _buildInfoSection('Favorite Games', player.favoriteGames.join(', ')),
        if (player.nationality != null)
          _buildInfoSection('Nationality', player.nationality!),
        _buildInfoSection('Status', player.status.name),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
