import 'package:esport_mgm/models/announcement.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/create_announcement_screen.dart';
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
                margin: const EdgeInsets.all(12.0),
                elevation: 4.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const CircleAvatar(child: Icon(Icons.person)),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(announcement.authorName, style: Theme.of(context).textTheme.titleMedium),
                              Text(DateFormat.yMMMd().add_jm().format(announcement.timestamp.toDate()), style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(announcement.title, style: Theme.of(context).textTheme.titleLarge),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(announcement.content),
                    ),
                    if (announcement.imageUrl != null)
                      Image.network(announcement.imageUrl!),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton.icon(icon: const Icon(Icons.thumb_up_outlined), label: const Text('Like'), onPressed: () {}),
                        TextButton.icon(icon: const Icon(Icons.comment_outlined), label: const Text('Comment'), onPressed: () {}),
                        TextButton.icon(icon: const Icon(Icons.share_outlined), label: const Text('Share'), onPressed: () {}),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateAnnouncementScreen(user: widget.user),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
