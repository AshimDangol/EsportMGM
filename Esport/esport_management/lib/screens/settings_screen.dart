import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/authentication_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:esport_mgm/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.user.theme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Email'),
            subtitle: Text(widget.user.email),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _currentTheme == 'dark',
            onChanged: (bool value) {
              final newTheme = value ? 'dark' : 'light';
              setState(() {
                _currentTheme = newTheme;
              });
              context.read<FirestoreService>().updateUserTheme(widget.user.id, newTheme);
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () {
              context.read<AuthenticationService>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
