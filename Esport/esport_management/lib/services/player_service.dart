import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/player.dart';

class PlayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _collection;

  PlayerService() {
    _collection = _firestore.collection('players');
  }

  Future<void> createPlayer(Player player) async {
    await _collection.add(player.toMap());
  }

  Future<void> updatePlayer(Player player) async {
    await _collection.doc(player.id).update(player.toMap());
  }

  Future<void> deletePlayer(String playerId) async {
    await _collection.doc(playerId).delete();
  }

  Future<Player?> getPlayerByUserId(String userId) async {
    final snapshot = await _collection.where('userId', isEqualTo: userId).get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return Player.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<Player>> getPlayers() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Player.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Stream<List<Player>> getPlayersStream() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Player.fromSnapshot(doc)).toList();
    });
  }
}
