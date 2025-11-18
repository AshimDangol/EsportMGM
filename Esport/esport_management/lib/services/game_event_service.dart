import 'package:esport_mgm/models/game_event.dart';
import 'package:mongo_dart/mongo_dart.dart';

class GameEventService {
  static const String _collection = 'game_events';
  final Db _db;

  GameEventService(this._db);

  DbCollection get eventCollection => _db.collection(_collection);

  Future<void> recordEvent(GameEvent event) async {
    await eventCollection.insert(event.toMap());
  }

  Future<List<GameEvent>> getEventsForMatch(String matchId) async {
    final docs = await eventCollection.find(where.eq('matchId', matchId).sortBy('timestamp')).toList();
    return docs.map((doc) => GameEvent.fromMap(doc)).toList();
  }
}
