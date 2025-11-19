import 'package:esport_mgm/models/sponsor.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/edit_sponsor_screen.dart';
import 'package:esport_mgm/services/sponsor_service.dart';
import 'package:flutter/material.dart';

class SponsorManagementScreen extends StatefulWidget {
  final User user;
  const SponsorManagementScreen({super.key, required this.user});

  @override
  State<SponsorManagementScreen> createState() => _SponsorManagementScreenState();
}

class _SponsorManagementScreenState extends State<SponsorManagementScreen> {
  final SponsorService _sponsorService = SponsorService();

  void _navigateToEditScreen([Sponsor? sponsor]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditSponsorScreen(user: widget.user, sponsor: sponsor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsor Management'),
      ),
      body: StreamBuilder<List<Sponsor>>(
        stream: _sponsorService.getSponsorsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sponsors found.'));
          }

          final sponsors = snapshot.data!;
          return ListView.builder(
            itemCount: sponsors.length,
            itemBuilder: (context, index) {
              final sponsor = sponsors[index];
              final bool isCreator = sponsor.creatorId == widget.user.id;
              return ListTile(
                title: Text(sponsor.name),
                subtitle: Text(sponsor.level.name),
                onTap: isCreator ? () => _navigateToEditScreen(sponsor) : null,
                trailing: isCreator
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _sponsorService.deleteSponsor(sponsor.id),
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
