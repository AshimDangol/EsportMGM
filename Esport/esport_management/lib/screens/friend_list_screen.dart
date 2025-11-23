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
  List<User> _searchResults = [];
  bool _isLoading = false;

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    final firestoreService = context.read<FirestoreService>();
    final results = await firestoreService.searchUsers(query);
    // Filter out the current user from the search results
    results.removeWhere((user) => user.id == widget.currentUser.id);
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
                return FutureBuilder<List<User>>(
                  future: firestoreService.getUsers(user.friendIds),
                  builder: (context, friendSnapshot) {
                    if (!friendSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final friends = friendSnapshot.data!;
                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return UserListTile(user: friends[index], currentUser: widget.currentUser);
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
                      labelText: 'Search by email',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      ),
                    ),
                    onChanged: _searchUsers,
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return UserListTile(user: _searchResults[index], currentUser: widget.currentUser);
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

class UserListTile extends StatelessWidget {
  final User user;
  final User currentUser;

  const UserListTile({super.key, required this.user, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final playerService = context.read<PlayerService>();

    return FutureBuilder<Player?>(
      future: playerService.getPlayerByUserId(user.id),
      builder: (context, snapshot) {
        final player = snapshot.data;
        final title = player?.gamerTag ?? user.email;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null ? const Icon(Icons.person) : null,
          ),
          title: Text(title),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(
                userId: user.id,
                currentUser: currentUser,
              ),
            ),
          ),
        );
      },
    );
  }
}
