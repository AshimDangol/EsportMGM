import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/sponsor.dart';

class SponsorService {
  final FirebaseFirestore _firestore;

  SponsorService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addSponsor(Sponsor sponsor) {
    return _firestore.collection('sponsors').add(sponsor.toMap());
  }

  Future<void> updateSponsor(Sponsor sponsor) {
    return _firestore.collection('sponsors').doc(sponsor.id).update(sponsor.toMap());
  }

  Future<void> deleteSponsor(String sponsorId) {
    return _firestore.collection('sponsors').doc(sponsorId).delete();
  }

  Stream<List<Sponsor>> getSponsorsStream() {
    return _firestore.collection('sponsors').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Sponsor.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}
