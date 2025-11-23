import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/ticket.dart';
import 'package:uuid/uuid.dart';

class TicketService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _collection;

  TicketService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection('tickets');
  }

  Future<void> purchaseTicket(String eventId, String userId, String ticketType, double price) async {
    final ticket = Ticket(
      id: const Uuid().v4(),
      eventId: eventId,
      userId: userId,
      ticketType: ticketType,
      price: price,
      createdAt: Timestamp.now(),
    );
    await _collection.doc(ticket.id).set(ticket.toMap());
  }

  Future<List<Ticket>> getTicketsForUser(String userId) async {
    final snapshot = await _collection.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Ticket.fromMap(doc.id, doc.data())).toList();
  }
}
