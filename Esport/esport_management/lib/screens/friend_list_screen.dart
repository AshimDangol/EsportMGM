import 'package:esport_mgm/models/player.dart';
import 'package:flutter/material.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:provider/provider.dart';
import 'package:esport_mgm/screens/user_profile_screen.dart';

class FriendListScreen extends StatefulWidget {
  final User currentUser;
  const FriendListScreen({super.key, required this.currentUser});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  final _searchController = TextEditingController();
  List<Player> _searchResults = [];
  bool _isLoading = false;

  void _searchPlayers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    final playerService = context.read<PlayerService>();
    final results = await playerService.searchPlayers(query);
    // Filter out the current user from the search results
    results.removeWhere((player) => player.userId == widget.currentUser.id);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Friends'),
              Tab(text: 'Find People'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // My Friends Tab
            StreamBuilder<User?>(
              stream: firestoreService.getUserStream(widget.currentUser.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final user = snapshot.data!;
                if (user.friendIds.isEmpty) {
                  return const Center(child: Text('You have no friends yet.'));
                }
                return FutureBuilder<List<Player>>(
                  future: context.read<PlayerService>().getPlayersByIds(user.friendIds),
                  builder: (context, playerSnapshot) {
                    if (!playerSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final friends = playerSnapshot.data!;
                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return PlayerListTile(player: friends[index], currentUser: widget.currentUser);
                      },
                    );
                  },
                );
              },
            ),
            // Find People Tab
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by GamerTag or ID',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      ),
                    ),
                    onChanged: _searchPlayers,
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return PlayerListTile(player: _searchResults[index], currentUser: widget.currentUser);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerListTile extends StatelessWidget {
  final Player player;
  final User currentUser;

  const PlayerListTile({super.key, required this.player, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();

    return FutureBuilder<User?>(
      // We fetch the user data to get the photoUrl
      future: firestoreService.getUser(player.userId).then((doc) => doc.exists ? User.fromMap(doc.id, doc.data()! as Map<String, dynamic>) : null),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
            child: user?.photoUrl == null ? const Icon(Icons.person) : null,
          ),
          title: Text(player.gamerTag),
          subtitle: Text(player.realName ?? 'No real name provided'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(
                userId: player.userId,
                currentUser: currentUser,
              ),
            ),
          ),
        );
      },
    );
  }
}
