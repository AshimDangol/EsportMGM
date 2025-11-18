import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/edit_player_screen.dart';
import 'package:esport_mgm/services/auth_service.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;
  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final PlayerService _playerService = PlayerService();
  Future<Player?>? _playerFuture;

  @override
  void initState() {
    super.initState();
    _playerFuture = _playerService.getPlayerByUserId(widget.user.id);
  }

  void _refresh() {
    setState(() {
      _playerFuture = _playerService.getPlayerByUserId(widget.user.id);
    });
  }

  void _navigateToPlayerScreen(Player? player) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPlayerScreen(user: widget.user, player: player),
      ),
    );
    _refresh(); // Refresh the profile screen after edits
  }

  // ... (build method and other widgets)
}
