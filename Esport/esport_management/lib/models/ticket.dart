
class Ticket {
  final String id;
  final String eventId;
  final String userId;
  final String ticketType;
  final double price;

  Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.ticketType,
    required this.price,
  });
}
