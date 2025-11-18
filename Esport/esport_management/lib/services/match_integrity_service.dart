import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/match_integrity_audit.dart';

class MatchIntegrityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _auditCollection;

  MatchIntegrityService() {
    _auditCollection = _firestore.collection('match_integrity_audits');
  }

  Future<void> createAudit(MatchIntegrityAudit audit) async {
    await _auditCollection.add(audit.toMap());
  }

  Future<List<MatchIntegrityAudit>> getAuditsForMatch(String matchId) async {
    final snapshot = await _auditCollection.where('matchId', isEqualTo: matchId).get();
    return snapshot.docs.map((doc) => MatchIntegrityAudit.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}
