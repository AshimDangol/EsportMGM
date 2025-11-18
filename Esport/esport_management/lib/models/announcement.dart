import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Announcement {
  final String id;
  final String title;
  final String content;
  final Timestamp timestamp;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  factory Announcement.fromMap(String id, Map<String, dynamic> map) {
    return Announcement(
      id: id,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
