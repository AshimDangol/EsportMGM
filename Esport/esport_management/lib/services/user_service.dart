import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/clan.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Clan?> getClanForUser(String userId) async {
    final snapshot = await _firestore
        .collection('clans')
        .where('memberIds', arrayContains: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return Clan.fromMap(doc.id, doc.data());
    }
    return null;
  }
}
