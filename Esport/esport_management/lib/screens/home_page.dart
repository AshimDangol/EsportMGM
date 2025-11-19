import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/announcements_screen.dart';
import 'package:esport_mgm/screens/clan_list_screen.dart';
import 'package:esport_mgm/screens/player_list_screen.dart';
import 'package:esport_mgm/screens/sponsor_management_screen.dart';
import 'package:esport_mgm/screens/talent_management_screen.dart';
import 'package:esport_mgm/screens/tournament_list_screen.dart';
import 'package:esport_mgm/screens/user_management_screen.dart';
import 'package:esport_mgm/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  bool get _isAdmin => user.role == UserRole.admin;

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
            if (_isAdmin)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.security, color: Colors.red),
                  title: const Text('User Management'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserManagementScreen()),
                    );
                  },
                ),
              ),
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
                title: const Text('Clans'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClanListScreen(user: user)),
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
            const Divider(),
            Card(
              child: ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.redAccent),
                title: const Text('Sponsors'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SponsorManagementScreen(user: user)),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.teal),
                title: const Text('Talent'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TalentManagementScreen(user: user)),
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
