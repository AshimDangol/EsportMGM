import 'package:esport_mgm/models/announcement.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/announcement_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatefulWidget {
  final User user;
  const AnnouncementsScreen({super.key, required this.user});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final AnnouncementService _announcementService = AnnouncementService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: _announcementService.getAnnouncementsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final announcements = snapshot.data ?? [];
          if (announcements.isEmpty) {
            return const Center(child: Text('No announcements yet.'));
          }

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(announcement.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(announcement.content),
                  trailing: Text(
                    DateFormat.yMMMd().format(announcement.timestamp.toDate()),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
