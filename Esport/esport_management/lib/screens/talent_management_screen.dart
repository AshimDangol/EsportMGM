import 'package:esport_mgm/models/talent.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:esport_mgm/services/talent_service.dart';
import 'package:flutter/material.dart';

class TalentManagementScreen extends StatefulWidget {
  const TalentManagementScreen({super.key});

  @override
  State<TalentManagementScreen> createState() => _TalentManagementScreenState();
}

class _TalentManagementScreenState extends State<TalentManagementScreen> {
  late final TalentService _talentService;
  Future<List<Talent>>? _talentFuture;

  @override
  void initState() {
    super.initState();
    _talentService = TalentService(DBService.instance.db);
    _loadTalent();
  }

  Future<void> _loadTalent() async {
    setState(() {
      _talentFuture = _talentService.getTalent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talent Management'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTalent,
        child: FutureBuilder<List<Talent>>(
          future: _talentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final talent = snapshot.data ?? [];
            if (talent.isEmpty) {
              return const Center(child: Text('No talent found.'));
            }
            return ListView.builder(
              itemCount: talent.length,
              itemBuilder: (context, index) {
                final person = talent[index];
                return ListTile(
                  title: Text(person.name),
                  subtitle: Text(person.role.toString().split('.').last),
                  trailing: Text(person.contactEmail),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTalentDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Add Talent',
      ),
    );
  }

  void _showAddTalentDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    TalentRole selectedRole = TalentRole.commentator;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Talent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Contact Email')),
            DropdownButton<TalentRole>(
              value: selectedRole,
              onChanged: (TalentRole? newValue) {
                if (newValue != null) {
                  // We need a StatefulWidget for the dialog to see the change
                  // For now, this just updates the variable.
                  selectedRole = newValue;
                }
              },
              items: TalentRole.values.map<DropdownMenuItem<TalentRole>>((TalentRole value) {
                return DropdownMenuItem<TalentRole>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
          TextButton(
            child: const Text('Add'),
            onPressed: () async {
              final name = nameController.text;
              final email = emailController.text;
              if (name.isEmpty || email.isEmpty) return;

              final newTalent = Talent(
                name: name,
                contactEmail: email,
                role: selectedRole,
              );

              await _talentService.addTalent(newTalent);
              Navigator.of(context).pop();
              _loadTalent();
            },
          ),
        ],
      ),
    );
  }
}
