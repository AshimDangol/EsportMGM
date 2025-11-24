import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/clan.dart';

class ClanService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _collection;

  ClanService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection('clans');
  }

  Stream<Clan?> getClanStream(String clanId) {
    return _collection.doc(clanId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Clan.fromMap(snapshot.id, snapshot.data()!);
      }
      return null;
    });
  }

  Future<void> createClan(Clan clan) async {
    await _collection.doc(clan.id).set(clan.toMap());
  }

  Future<Clan?> getClanById(String clanId) async {
    final doc = await _collection.doc(clanId).get();
    if (doc.exists) {
      return Clan.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Future<List<Clan>> getClansByIds(List<String> clanIds) async {
    if (clanIds.isEmpty) return [];
    final snapshot = await _collection.where(FieldPath.documentId, whereIn: clanIds).get();
    return snapshot.docs.map((doc) => Clan.fromMap(doc.id, doc.data()!)).toList();
  }

  Future<List<Clan>> getAllClans() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Clan.fromMap(doc.id, doc.data()!)).toList();
  }

  Future<Clan?> getClanForUser(String userId) async {
    final snapshot = await _collection.where('memberIds', arrayContains: userId).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return Clan.fromMap(snapshot.docs.first.id, snapshot.docs.first.data()!);
    }
    return null;
  }

  Future<List<Clan>> searchClans(String query) async {
    if (query.isEmpty) return [];
    
    final byName = _collection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();

    final byCode = _collection.where('joinCode', isEqualTo: query.toUpperCase()).get();

    final results = await Future.wait([byName, byCode]);
    final Set<Clan> clans = {};

    for (var snapshot in results) {
      for (var doc in snapshot.docs) {
        clans.add(Clan.fromMap(doc.id, doc.data()!));
      }
    }
    return clans.toList();
  }

  Future<void> joinClan(String clanId, String userId) async {
    await _collection.doc(clanId).update({
      'memberIds': FieldValue.arrayUnion([userId])
    });
  }
  
  Future<void> requestToJoinClan(String clanId, String userId) async {
    await _collection.doc(clanId).update({
      'pendingMemberIds': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> approveJoinRequest(String clanId, String userId) async {
    await _collection.doc(clanId).update({
      'pendingMemberIds': FieldValue.arrayRemove([userId]),
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> rejectJoinRequest(String clanId, String userId) async {
    await _collection.doc(clanId).update({
      'pendingMemberIds': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> leaveClan(String clanId, String userId) async {
    await _collection.doc(clanId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'coAdminIds': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> removePlayerFromClan(String clanId, String userId) async {
    await leaveClan(clanId, userId);
  }

  Future<void> promoteToAdmin(String clanId, String newOwnerId) async {
    await _collection.doc(clanId).update({
      'ownerId': newOwnerId,
    });
  }

  Future<void> promoteToCoAdmin(String clanId, String userId, bool isCoAdmin) async {
    final update = isCoAdmin
        ? {'coAdminIds': FieldValue.arrayUnion([userId])}
        : {'coAdminIds': FieldValue.arrayRemove([userId])};
    await _collection.doc(clanId).update(update);
  }

  Future<void> updateClanPrivacy(String clanId, ClanPrivacy privacy) async {
    await _collection.doc(clanId).update({'privacy': privacy.name});
  }
}
