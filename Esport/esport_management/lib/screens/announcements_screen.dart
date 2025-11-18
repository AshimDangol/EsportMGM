import 'package:esport_mgm/models/announcement.dart';
import 'package:esport_mgm/services/announcement_service.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late final AnnouncementService _announcementService;
  Future<List<Announcement>>? _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _announcementService = AnnouncementService(DBService.instance.db);
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _announcementsFuture = _announcementService.getAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnnouncements,
        child: FutureBuilder<List<Announcement>>(
          future: _announcementsFuture,
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
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(announcement.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'By ${announcement.authorId} on ${announcement.timestamp.toLocal()}\n\n${announcement.content}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
