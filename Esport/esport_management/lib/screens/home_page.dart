import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/announcements_screen.dart';
import 'package:esport_mgm/screens/player_list_screen.dart';
import 'package:esport_mgm/screens/team_list_screen.dart';
import 'package:esport_mgm/screens/tournament_list_screen.dart';
import 'package:esport_mgm/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esports Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen(user: user)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Card(
              child: ListTile(
                leading: const Icon(Icons.rss_feed, color: Colors.purple),
                title: const Text('Feed'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnnouncementsScreen(user: user)),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.blueAccent),
                title: const Text('Tournaments'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TournamentListScreen(user: user)),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.group, color: Colors.green),
                title: const Text('Teams'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TeamListScreen(user: user)),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_search, color: Colors.orange),
                title: const Text('Players'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlayerListScreen(user: user)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
