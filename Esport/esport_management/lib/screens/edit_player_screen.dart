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
  // ... (form key, service, and state variables)

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
      // ... (save logic)
      // Ensure the createPlayer call uses the correct, non-editable userId
      if (isEditing) {
        // ... update logic
      } else {
        await _playerService.createPlayer(_gamerTag, _userId, realName: _realName, nationality: _nationality);
      }
      // ... (pop navigator)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ... (app bar title and delete action)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ... gamerTag, realName, nationality fields
                // The userId field is removed from the form as it is now handled automatically.
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
