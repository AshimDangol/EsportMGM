import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class EditPlayerScreen extends StatefulWidget {
  final User user;
  final Player? player;

  const EditPlayerScreen({super.key, required this.user, this.player});

  @override
  State<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final PlayerService _playerService = PlayerService();
  final FirestoreService _firestoreService = FirestoreService();

  late String _gamerTag;
  String? _realName;
  String? _nationality;
  UserRole _selectedRole = UserRole.player; // Default role for new players
  PlayerStatus _selectedStatus = PlayerStatus.active;

  bool get _isEditing => widget.player != null;
  bool get _isAdmin => widget.user.role == UserRole.admin;

  @override
  void initState() {
    super.initState();
    _gamerTag = widget.player?.gamerTag ?? '';
    _realName = widget.player?.realName;
    _nationality = widget.player?.nationality;
    _selectedStatus = widget.player?.status ?? PlayerStatus.active;
    // When editing, we should fetch the user's current role
    if (_isEditing) {
      _firestoreService.getUser(widget.player!.userId).then((user) {
        if (user != null) {
          setState(() {
            _selectedRole = user.role;
          });
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String targetUserId;
      if (_isEditing) {
        targetUserId = widget.player!.userId;
      } else {
        // Create a new user for the new player
        targetUserId = const Uuid().v4();
        // You should have a more robust way of creating users, this is a simplification
        await _firestoreService.createUser(targetUserId, '${_gamerTag.toLowerCase().replaceAll(' ', '.')}@email.com');
      }

      final player = Player(
        id: _isEditing ? widget.player!.id : const Uuid().v4(),
        userId: targetUserId,
        gamerTag: _gamerTag,
        realName: _realName,
        nationality: _nationality,
        status: _selectedStatus,
      );

      if (_isEditing) {
        await _playerService.updatePlayer(player);
      } else {
        await _playerService.addPlayer(player);
      }

      // Update the user's role
      if (_isAdmin) {
        await _firestoreService.updateUserRole(targetUserId, _selectedRole);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Player' : 'Create Player'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _gamerTag,
                decoration: const InputDecoration(labelText: 'Gamer Tag'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a gamer tag';
                  }
                  return null;
                },
                onSaved: (value) => _gamerTag = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _realName,
                decoration: const InputDecoration(labelText: 'Real Name'),
                onSaved: (value) => _realName = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _nationality,
                decoration: const InputDecoration(labelText: 'Nationality'),
                onSaved: (value) => _nationality = value,
              ),
              if (_isAdmin) ...[
                const SizedBox(height: 24),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Assign Role'),
                  items: UserRole.values.map((UserRole role) {
                    return DropdownMenuItem<UserRole>(
                      value: role,
                      child: Text(role.name),
                    );
                  }).toList(),
                  onChanged: (UserRole? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PlayerStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Player Status'),
                  items: PlayerStatus.values.map((PlayerStatus status) {
                    return DropdownMenuItem<PlayerStatus>(
                      value: status,
                      child: Text(status.name),
                    );
                  }).toList(),
                  onChanged: (PlayerStatus? newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                    });
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Update Player' : 'Create Player'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
