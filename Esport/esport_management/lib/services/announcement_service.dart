import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/announcement.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore;

  AnnouncementService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream of announcements, ordered by the most recent
  Stream<List<Announcement>> getAnnouncementsStream() {
    return _firestore
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Announcement.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Add a new announcement
  Future<void> addAnnouncement(Announcement announcement) {
    return _firestore.collection('announcements').add(announcement.toMap());
  }
}
