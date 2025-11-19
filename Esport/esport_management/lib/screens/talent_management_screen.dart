import 'package:esport_mgm/models/talent.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/edit_talent_screen.dart';
import 'package:esport_mgm/services/talent_service.dart';
import 'package:flutter/material.dart';

class TalentManagementScreen extends StatefulWidget {
  final User user;
  const TalentManagementScreen({super.key, required this.user});

  @override
  State<TalentManagementScreen> createState() => _TalentManagementScreenState();
}

class _TalentManagementScreenState extends State<TalentManagementScreen> {
  final TalentService _talentService = TalentService();

  void _navigateToEditScreen([Talent? talent]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTalentScreen(user: widget.user, talent: talent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talent Management'),
      ),
      body: StreamBuilder<List<Talent>>(
        stream: _talentService.getTalentStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No talent found.'));
          }

          final talent = snapshot.data!;
          return ListView.builder(
            itemCount: talent.length,
            itemBuilder: (context, index) {
              final person = talent[index];
              final bool isCreator = person.creatorId == widget.user.id;
              return ListTile(
                title: Text(person.name),
                subtitle: Text(person.role.name),
                onTap: isCreator ? () => _navigateToEditScreen(person) : null,
                trailing: isCreator
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _talentService.deleteTalent(person.id),
                      )
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
