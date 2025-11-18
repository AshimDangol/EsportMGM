import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/player_selection_screen.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:flutter/material.dart';

class EditTeamScreen extends StatefulWidget {
  final User user;
  final Team? team;

  const EditTeamScreen({super.key, required this.user, this.team});

  @override
  State<EditTeamScreen> createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends State<EditTeamScreen> {
  // ... (state variables)

  bool get isEditing => widget.team != null;

  bool get _canEdit {
    if (widget.user.role == UserRole.admin) {
      return true;
    }
    if (widget.user.role == UserRole.teamManager &&
        isEditing &&
        widget.team!.managerId == widget.user.id) {
      return true;
    }
    if (!isEditing && widget.user.role == UserRole.teamManager) {
      return true; // Can create a new team
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    // ... (rest of initState)
    // When creating a new team, pre-fill the manager ID with the current user
    _managerId = widget.team?.managerId ?? widget.user.id;
  }

  // ... (other methods)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Team' : 'Create Team'),
        actions: [
          if (isEditing && _canEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () { /* ... delete logic ... */ },
            )
        ],
      ),
      body: AbsorbPointer(
        absorbing: !_canEdit,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ... (form fields)
                  // The manager ID field should be read-only if the user is a manager
                  TextFormField(
                    initialValue: _managerId,
                    readOnly: widget.user.role == UserRole.teamManager,
                    decoration: const InputDecoration(labelText: 'Manager ID'),
                  ),
                  // ... (player list and other widgets)
                  ElevatedButton(
                    onPressed: _canEdit ? _saveForm : null,
                    child: Text(isEditing ? 'Update' : 'Create'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
