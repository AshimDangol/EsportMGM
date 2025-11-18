
import 'package:esport_mgm/models/announcement.dart';
import 'package:esport_mgm/services/feed_service.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedService _feedService = FeedService();
    final List<Announcement> announcements = _feedService.getAnnouncements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          Announcement announcement = announcements[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(announcement.title),
              subtitle: Text(announcement.content),
            ),
          );
        },
      ),
    );
  }
}
