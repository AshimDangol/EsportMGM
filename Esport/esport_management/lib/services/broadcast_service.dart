import 'package:esport_mgm/models/broadcast_schedule.dart';
import 'package:mongo_dart/mongo_dart.dart';

class BroadcastService {
  static const String _collection = 'broadcast_schedules';
  final Db _db;

  BroadcastService(this._db);

  DbCollection get scheduleCollection => _db.collection(_collection);

  Future<void> addScheduleItem(BroadcastScheduleItem item) async {
    await scheduleCollection.insert(item.toMap());
  }

  Future<List<BroadcastScheduleItem>> getScheduleForTournament(String tournamentId) async {
    final docs = await scheduleCollection.find(where.eq('tournamentId', tournamentId).sortBy('startTime')).toList();
    return docs.map((doc) => BroadcastScheduleItem.fromMap(doc)).toList();
  }

  Future<void> updateScheduleItem(BroadcastScheduleItem item) async {
    await scheduleCollection.updateOne(where.id(item.id), item.toMap());
  }

  Future<void> deleteScheduleItem(ObjectId itemId) async {
    await scheduleCollection.deleteOne(where.id(itemId));
  }
}
