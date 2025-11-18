import 'package:esport_mgm/models/player_discipline.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PlayerDisciplineService {
  static const String _collection = 'player_discipline';
  final Db _db;

  PlayerDisciplineService(this._db);

  DbCollection get disciplineCollection => _db.collection(_collection);

  Future<PlayerDiscipline?> getDisciplineRecord(String playerId) async {
    final doc = await disciplineCollection.findOne(where.eq('playerId', playerId));
    return doc == null ? null : PlayerDiscipline.fromMap(doc);
  }

  Future<void> suspendPlayer(
      String playerId, String reason, String adminId, DateTime endDate) async {
    final action = DisciplinaryAction(status: PlayerStatus.suspended, reason: reason, performedBy: adminId);

    await disciplineCollection.updateOne(
      where.eq('playerId', playerId),
      modify
          .set('currentStatus', PlayerStatus.suspended.toString())
          .set('suspensionEndDate', endDate)
          .push('history', action.toMap()),
      upsert: true,
    );
  }

  Future<void> banPlayer(String playerId, String reason, String adminId) async {
    final action = DisciplinaryAction(status: PlayerStatus.banned, reason: reason, performedBy: adminId);

    await disciplineCollection.updateOne(
      where.eq('playerId', playerId),
      modify
          .set('currentStatus', PlayerStatus.banned.toString())
          .unset('suspensionEndDate')
          .push('history', action.toMap()),
      upsert: true,
    );
  }

  Future<void> pardonPlayer(String playerId, String reason, String adminId) async {
    final action = DisciplinaryAction(status: PlayerStatus.active, reason: reason, performedBy: adminId);

    await disciplineCollection.updateOne(
      where.eq('playerId', playerId),
      modify
          .set('currentStatus', PlayerStatus.active.toString())
          .unset('suspensionEndDate')
          .push('history', action.toMap()),
      upsert: true,
    );
  }
}
