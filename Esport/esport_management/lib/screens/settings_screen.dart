import 'dart:io';

import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/authentication_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:esport_mgm/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _gamerTagController;
  late final TextEditingController _favoriteGameController;

  String? _photoUrl;
  File? _imageFile;
  Player? _player;
  late PlayerStatus _selectedStatus;
  late List<String> _favoriteGames;

  @override
  void initState() {
    super.initState();
    _gamerTagController = TextEditingController();
    _favoriteGameController = TextEditingController();
    _selectedStatus = PlayerStatus.active;
    _favoriteGames = [];
    _photoUrl = widget.user.photoUrl;
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    setState(() => _isLoading = true);
    final player = await context.read<PlayerService>().getPlayerByUserId(widget.user.id);
    if (player != null) {
      _player = player;
      _gamerTagController.text = player.gamerTag;
      _selectedStatus = player.status;
      _favoriteGames = List.from(player.favoriteGames);
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _gamerTagController.dispose();
    _favoriteGameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final playerService = context.read<PlayerService>();
    final firestoreService = context.read<FirestoreService>();

    try {
      String? newPhotoUrl = _photoUrl;
      if (_imageFile != null) {
        // Here you would typically upload the file to a cloud storage and get the URL
        // For now, we'll just use the file path as a placeholder
        newPhotoUrl = _imageFile!.path;
      }

      // Update the User document with the photo URL
      await firestoreService.updateUserTheme(widget.user.id, newPhotoUrl ?? ''); // Reusing this method for simplicity

      final playerToSave = (_player ?? Player(id: widget.user.id, userId: widget.user.id, gamerTag: '')).copyWith(
        gamerTag: _gamerTagController.text,
        status: _selectedStatus,
        favoriteGames: _favoriteGames,
      );

      if (_player == null) {
        await playerService.addPlayer(playerToSave);
      } else {
        await playerService.updatePlayer(playerToSave);
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Saved!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
    }

    setState(() => _isLoading = false);
  }

  void _addFavoriteGame() {
    final game = _favoriteGameController.text.trim();
    if (game.isNotEmpty && !_favoriteGames.contains(game)) {
      setState(() {
        _favoriteGames.add(game);
        _favoriteGameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthenticationService>().signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : (_photoUrl != null && _photoUrl!.isNotEmpty ? NetworkImage(_photoUrl!) : null)
                                    as ImageProvider?,
                            child: _imageFile == null && (_photoUrl == null || _photoUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 60)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: _pickImage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _gamerTagController,
                      decoration: const InputDecoration(labelText: 'GamerTag', border: OutlineInputBorder()),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a GamerTag' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<PlayerStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(labelText: 'Online Status', border: OutlineInputBorder()),
                      items: PlayerStatus.values.map((status) {
                        return DropdownMenuItem(value: status, child: Text(status.name));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedStatus = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildFavoriteGamesSection(),
                    const Divider(height: 32),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Save Profile'),
                    ),
                    const SizedBox(height: 16),
                     SwitchListTile(
                        title: const Text('Dark Mode'),
                        value: themeNotifier.value == ThemeMode.dark,
                        onChanged: (bool value) {
                          final newTheme = value ? ThemeMode.dark : ThemeMode.light;
                          // context.read<FirestoreService>().updateUserTheme(widget.user.id, value ? 'dark' : 'light');
                          themeNotifier.value = newTheme;
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFavoriteGamesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Favorite Games', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _favoriteGames.map((game) {
            return Chip(
              label: Text(game),
              onDeleted: () {
                setState(() => _favoriteGames.remove(game));
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _favoriteGameController,
                decoration: const InputDecoration(labelText: 'Add a game'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addFavoriteGame,
            ),
          ],
        ),
      ],
    );
  }
}
