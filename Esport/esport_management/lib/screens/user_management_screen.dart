import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _firestoreService.getAllUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _firestoreService.getAllUsers();
    });
  }

  void _showRoleDialog(User user) {
    showDialog(
      context: context,
      builder: (context) {
        UserRole selectedRole = user.role;
        return AlertDialog(
          title: Text('Change Role for ${user.email}'),
          content: DropdownButton<UserRole>(
            value: selectedRole,
            items: UserRole.values.map((role) {
              return DropdownMenuItem<UserRole>(value: role, child: Text(role.name));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                selectedRole = value;
              }
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await _firestoreService.updateUserRole(user.id, selectedRole);
                _refreshUsers();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.email),
                subtitle: Text(user.role.name),
                onTap: () => _showRoleDialog(user),
              );
            },
          );
        },
      ),
    );
  }
}
