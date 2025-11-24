import 'dart:io';

import 'package:esport_mgm/models/announcement.dart';
import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/create_announcement_screen.dart';
import 'package:esport_mgm/services/announcement_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatelessWidget {
  final User user;
  const AnnouncementsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final announcementService = context.watch<AnnouncementService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: announcementService.getAnnouncementsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No announcements yet.'));
          }

          final announcements = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return AnnouncementCard(announcement: announcement);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateAnnouncementScreen(user: user),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementCard({super.key, required this.announcement});

  Widget _buildImage(String imageUrl) {
    bool isLocal = !imageUrl.startsWith('http');
    if (isLocal) {
      return Image.file(File(imageUrl));
    } else {
      return Image.network(imageUrl);
    }
  }

  ImageProvider _getAvatarImage(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (!photoUrl.startsWith('http')) {
        return FileImage(File(photoUrl));
      }
      return NetworkImage(photoUrl);
    }
    // In a real app, you would have a default avatar image in your assets.
    return const Icon(Icons.person).toString() as ImageProvider;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final playerService = context.read<PlayerService>();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<User?>(
              future: firestoreService.getUserStream(announcement.authorId).first,
              builder: (context, userSnapshot) {
                final user = userSnapshot.data;
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: _getAvatarImage(user?.photoUrl),
                      child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 24)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<Player?>(
                          future: playerService.getPlayerByUserId(announcement.authorId),
                          builder: (context, playerSnapshot) {
                            String displayName = announcement.authorName; // Default to email
                            if (playerSnapshot.connectionState == ConnectionState.done && playerSnapshot.hasData) {
                              displayName = playerSnapshot.data!.gamerTag;
                            }
                            return Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
                          },
                        ),
                        Text(
                          DateFormat.yMMMd().add_jm().format(announcement.timestamp.toDate()),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(announcement.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(announcement.content, style: const TextStyle(fontSize: 15)),
            if (announcement.imageUrl != null && announcement.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildImage(announcement.imageUrl!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
