import 'package:mongo_dart/mongo_dart.dart';

enum TicketStatus {
  valid,
  checkedIn,
  voided,
}

class Ticket {
  final ObjectId id;
  final String tournamentId;
  final String userId; // The spectator who owns the ticket
  final DateTime purchaseDate;
  DateTime? checkInDate;
  TicketStatus status;

  Ticket({
    required this.tournamentId,
    required this.userId,
  })  : id = ObjectId(),
        purchaseDate = DateTime.now(),
        status = TicketStatus.valid;

  Map<String, dynamic> toMap() => {
        '_id': id,
        'tournamentId': tournamentId,
        'userId': userId,
        'purchaseDate': purchaseDate,
        'checkInDate': checkInDate,
        'status': status.toString(),
      };

  factory Ticket.fromMap(Map<String, dynamic> map) {
    final ticket = Ticket(
      tournamentId: map['tournamentId'] as String,
      userId: map['userId'] as String,
    )
      ..id.id = map['_id'] as ObjectId
      ..purchaseDate.toUtc() // Simplified timestamp handling
      ..checkInDate = map['checkInDate'] as DateTime?
      ..status = TicketStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => TicketStatus.voided,
      );
    return ticket;
  }
}
