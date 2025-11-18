import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/player_discipline_screen.dart';
import 'package:esport_mgm/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    _currentUser = await _authService.getCurrentUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // For demonstration, we'll use a hardcoded player ID.
    // In a real app, you'd get this from the user's profile or another source.
    const String hardcodedPlayerId = "test_player_123";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          )
        ],
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email: ${_currentUser!.email}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  // This would be conditionally shown to admins
                  ElevatedButton.icon(
                    icon: const Icon(Icons.security),
                    label: const Text('Manage Player Discipline'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlayerDisciplineScreen(playerId: hardcodedPlayerId),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
