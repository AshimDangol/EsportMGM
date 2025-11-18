import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/services/db_exception.dart';
import 'package:esport_mgm/services/mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PlayerService {
  final _db = MongoService().db;
  DbCollection get _collection {
    final collection = _db?.collection('players');
    if (collection == null) {
      throw DbException('Database not connected or collection not found.');
    }
    return collection;
  }

  // ... (create, get, update, delete methods)

  Future<Player?> getPlayerByUserId(String userId) async {
    try {
      final playerMap = await _collection.findOne(where.eq('userId', userId));
      if (playerMap != null) {
        return Player.fromMap(playerMap);
      }
      return null;
    } catch (e) {
      throw DbException('Error fetching player by user ID: $e');
    }
  }

  // ... (getPlayersByIds method)
}
