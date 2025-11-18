import 'package:mongo_dart/mongo_dart.dart';

class Announcement {
  final ObjectId id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String authorId; // ID of the admin who posted it

  Announcement({
    required this.title,
    required this.content,
    required this.authorId,
  })  : id = ObjectId(),
        timestamp = DateTime.now();

  Map<String, dynamic> toMap() => {
        '_id': id,
        'title': title,
        'content': content,
        'timestamp': timestamp,
        'authorId': authorId,
      };

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      title: map['title'] as String,
      content: map['content'] as String,
      authorId: map['authorId'] as String,
    )
      ..id.id = map['_id'] as ObjectId
      ..timestamp.toUtc(); // Simplified timestamp handling
  }
}
