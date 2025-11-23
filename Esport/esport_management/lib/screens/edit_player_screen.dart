import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  late String _gamerTag;
  String? _realName;
  String? _nationality;
  PlayerStatus _selectedStatus = PlayerStatus.active;

  bool get _isEditing => widget.player != null;

  @override
  void initState() {
    super.initState();
    _gamerTag = widget.player?.gamerTag ?? '';
    _realName = widget.player?.realName;
    _nationality = widget.player?.nationality;
    _selectedStatus = widget.player?.status ?? PlayerStatus.active;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final playerService = context.read<PlayerService>();

      final player = Player(
        id: _isEditing ? widget.player!.id : const Uuid().v4(),
        userId: widget.user.id,
        gamerTag: _gamerTag,
        realName: _realName,
        nationality: _nationality,
        status: _selectedStatus,
      );

      if (_isEditing) {
        await playerService.updatePlayer(player);
      } else {
        await playerService.addPlayer(player);
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
