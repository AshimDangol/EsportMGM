import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Announcement {
  final String id;
  final String title;
  final String content;
  final Timestamp timestamp;
  final String authorName;
  final String? imageUrl;
  final String authorId;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.authorName,
    this.imageUrl,
    required this.authorId,
  });

  factory Announcement.fromMap(String id, Map<String, dynamic> map) {
    return Announcement(
      id: id,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
      authorName: map['authorName'] as String? ?? 'Anonymous',
      imageUrl: map['imageUrl'] as String?,
      authorId: map['authorId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'authorName': authorName,
      'imageUrl': imageUrl,
      'authorId': authorId,
    };
  }
}
