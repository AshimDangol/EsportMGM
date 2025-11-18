import 'package:esport_mgm/models/announcement.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AnnouncementService {
  static const String _collection = 'announcements';
  final Db _db;

  AnnouncementService(this._db);

  DbCollection get announcementCollection => _db.collection(_collection);

  Future<void> createAnnouncement(Announcement announcement) async {
    await announcementCollection.insert(announcement.toMap());
  }

  Future<List<Announcement>> getAnnouncements() async {
    // Sort by newest first
    final docs = await announcementCollection.find(where.sortBy('timestamp', descending: true)).toList();
    return docs.map((doc) => Announcement.fromMap(doc)).toList();
  }
}
