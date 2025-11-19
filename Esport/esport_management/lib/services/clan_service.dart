import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/player_role.dart';

class ClanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _collection;

  ClanService() {
    _collection = _firestore.collection('clans');
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

  Future<void> joinClan(String clanId, String userId) async {
    await _collection.doc(clanId).update({
      'memberIds': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> leaveClan(String clanId, String userId) async {
    await _collection.doc(clanId).update({
      'memberIds': FieldValue.arrayRemove([userId])
    });
  }

  Future<void> updateClanRole(String clanId, String userId, PlayerRole role) async {
    await _collection.doc(clanId).update({
      'roles.$userId': role.name,
    });
  }
}
