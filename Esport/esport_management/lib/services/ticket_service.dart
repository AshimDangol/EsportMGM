import 'package:esport_mgm/models/ticket.dart';
import 'package:mongo_dart/mongo_dart.dart';

class TicketService {
  static const String _collection = 'tickets';
  final Db _db;

  TicketService(this._db);

  DbCollection get ticketCollection => _db.collection(_collection);

  Future<Ticket> issueTicket(String tournamentId, String userId) async {
    final ticket = Ticket(tournamentId: tournamentId, userId: userId);
    await ticketCollection.insert(ticket.toMap());
    return ticket;
  }

  Future<List<Ticket>> getTicketsForUser(String userId) async {
    final docs = await ticketCollection.find(where.eq('userId', userId)).toList();
    return docs.map((doc) => Ticket.fromMap(doc)).toList();
  }

  Future<Ticket?> getTicketById(String ticketId) async {
    final doc = await ticketCollection.findOne(where.id(ObjectId.parse(ticketId)));
    return doc == null ? null : Ticket.fromMap(doc);
  }

  Future<bool> checkInTicket(String ticketId) async {
    final result = await ticketCollection.updateOne(
      where.id(ObjectId.parse(ticketId)).and(where.eq('status', TicketStatus.valid.toString())),
      modify
          .set('status', TicketStatus.checkedIn.toString())
          .set('checkInDate', DateTime.now()),
    );

    return result.nModified == 1;
  }
}
