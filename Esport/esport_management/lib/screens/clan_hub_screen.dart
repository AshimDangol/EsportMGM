import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/clan_list_screen.dart';
import 'package:esport_mgm/screens/my_clans_screen.dart';
import 'package:flutter/material.dart';

class ClanHubScreen extends StatelessWidget {
  final User user;
  const ClanHubScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clans'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHubButton(
              context,
              icon: Icons.group,
              label: 'My Clans',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MyClansScreen(user: user)),
              ),
            ),
            const SizedBox(height: 20),
            _buildHubButton(
              context,
              icon: Icons.search,
              label: 'Find a Clan',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ClanListScreen(user: user)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 24),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      icon: Icon(icon, size: 28),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
