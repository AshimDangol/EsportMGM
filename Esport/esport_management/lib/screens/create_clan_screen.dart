import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateClanScreen extends StatefulWidget {
  final User user;
  const CreateClanScreen({super.key, required this.user});

  @override
  State<CreateClanScreen> createState() => _CreateClanScreenState();
}

class _CreateClanScreenState extends State<CreateClanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clanService = ClanService();
  final _nameController = TextEditingController();
  final _tagController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _createClan() async {
    final user = context.read<User?>();
    if (user?.role != UserRole.clan_leader) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to create clans.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final clan = Clan(
        id: const Uuid().v4(),
        name: _nameController.text,
        tag: _tagController.text,
        ownerId: widget.user.id,
        memberIds: [widget.user.id],
      );
      await _clanService.createClan(clan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clan Created!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create clan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Clan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Clan Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a clan name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(labelText: 'Clan Tag'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a clan tag';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _createClan,
                  child: const Text('Create'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
