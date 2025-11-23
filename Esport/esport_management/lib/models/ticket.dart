import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Ticket {
  final String id;
  final String eventId;
  final String userId;
  final String ticketType;
  final double price;
  final Timestamp createdAt;

  const Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.ticketType,
    required this.price,
    required this.createdAt,
  });

  factory Ticket.fromMap(String id, Map<String, dynamic> map) {
    return Ticket(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      ticketType: map['ticketType'] as String? ?? '',
      price: (map['price'] as num? ?? 0.0).toDouble(),
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'ticketType': ticketType,
      'price': price,
      'createdAt': createdAt,
    };
  }
}
