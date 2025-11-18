
import 'package:esport_mgm/models/announcement.dart';

class FeedService {
  // In a real app, you would fetch this from a database
  final List<Announcement> _announcements = [
    Announcement(title: 'Welcome to the Esports Management App!', content: 'We are excited to have you here.'),
    Announcement(title: 'New Tournament Announced!', content: 'Check out the tournaments page for more details.'),
  ];

  List<Announcement> getAnnouncements() {
    return _announcements;
  }
}
