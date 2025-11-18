import 'package:esport_mgm/models/match_integrity_audit.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MatchIntegrityService {
  static const String _collection = 'match_integrity_audits';
  final Db _db;

  MatchIntegrityService(this._db);

  DbCollection get auditCollection => _db.collection(_collection);

  Future<void> createAudit(MatchIntegrityAudit audit) async {
    await auditCollection.insert(audit.toMap());
  }

  Future<List<MatchIntegrityAudit>> getAuditsForMatch(String matchId) async {
    final docs = await auditCollection.find(where.eq('matchId', matchId)).toList();
    return docs.map((doc) => MatchIntegrityAudit.fromMap(doc)).toList();
  }
}
