import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';

class EditPlayerScreen extends StatefulWidget {
  final User user; // The user creating/editing the profile
  final Player? player;

  const EditPlayerScreen({super.key, required this.user, this.player});

  @override
  State<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerService = PlayerService();

  late String _gamerTag;
  late String _userId;
  String? _realName;
  String? _nationality;

  bool get isEditing => widget.player != null;

  @override
  void initState() {
    super.initState();
    _gamerTag = widget.player?.gamerTag ?? '';
    // The userId is always the current user. It cannot be changed.
    _userId = widget.user.id;
    _realName = widget.player?.realName;
    _nationality = widget.player?.nationality;
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        if (isEditing) {
          final updatedPlayer = widget.player!.copyWith(
            gamerTag: _gamerTag,
            realName: _realName,
            nationality: _nationality,
          );
          await _playerService.updatePlayer(updatedPlayer);
        } else {
          final newPlayer = Player(
            id: 'temporary-id', // Firestore will generate an ID
            userId: _userId,
            gamerTag: _gamerTag,
            realName: _realName,
            nationality: _nationality,
          );
          await _playerService.createPlayer(newPlayer);
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving player: $e')),
          );
        }
      }
    }
  }

    void _deletePlayer() async {
    if (!isEditing) return;
    try {
      await _playerService.deletePlayer(widget.player!.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting player: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Player' : 'Create Player'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deletePlayer,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _gamerTag,
                  decoration: const InputDecoration(labelText: 'Gamer Tag'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a gamer tag' : null,
                  onSaved: (value) => _gamerTag = value!,
                ),
                TextFormField(
                  initialValue: _realName,
                  decoration: const InputDecoration(labelText: 'Real Name'),
                  onSaved: (value) => _realName = value,
                ),
                TextFormField(
                  initialValue: _nationality,
                  decoration: const InputDecoration(labelText: 'Nationality'),
                  onSaved: (value) => _nationality = value,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveForm,
                  child: Text(isEditing ? 'Update' : 'Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
