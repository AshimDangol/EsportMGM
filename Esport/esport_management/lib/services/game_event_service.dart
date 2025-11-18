import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/game_event.dart';

class GameEventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _eventsCollection;

  GameEventService() {
    _eventsCollection = _firestore.collection('game_events');
  }

  Future<void> recordEvent(GameEvent event) async {
    await _eventsCollection.add(event.toMap());
  }

  Future<List<GameEvent>> getEventsForMatch(String matchId) async {
    final snapshot = await _eventsCollection.where('matchId', isEqualTo: matchId).orderBy('timestamp').get();
    return snapshot.docs.map((doc) => GameEvent.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}
