import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Training {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String clanId;

  const Training({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.clanId,
  });

  factory Training.fromMap(String id, Map<String, dynamic> data) {
    return Training(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      clanId: data['clanId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'clanId': clanId,
    };
  }
}
