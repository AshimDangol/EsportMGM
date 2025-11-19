import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/talent.dart';

class TalentService {
  final FirebaseFirestore _firestore;

  TalentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addTalent(Talent talent) {
    return _firestore.collection('talent').add(talent.toMap());
  }

  Future<void> updateTalent(Talent talent) {
    return _firestore.collection('talent').doc(talent.id).update(talent.toMap());
  }

  Future<void> deleteTalent(String talentId) {
    return _firestore.collection('talent').doc(talentId).delete();
  }

  Stream<List<Talent>> getTalentStream() {
    return _firestore.collection('talent').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Talent.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}
