import 'package:esport_mgm/models/user.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ... (existing buttons)
          ],
        ),
      ),
    );
  }
}
