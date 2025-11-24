import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/player.dart';

class PlayerService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _collection;

  PlayerService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection('players');
  }

  Future<bool> _isGamerTagTaken(String gamerTag, {String? currentPlayerId}) async {
    final query = _collection.where('gamerTag', isEqualTo: gamerTag);
    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      return false;
    }
    // If we are updating, we need to make sure the found tag doesn't belong to the current player
    if (currentPlayerId != null && snapshot.docs.first.id == currentPlayerId) {
      return false;
    }
    return true;
  }

  Future<void> addPlayer(Player player) async {
    if (await _isGamerTagTaken(player.gamerTag)) {
      throw Exception('GamerTag is already taken.');
    }
    await _collection.doc(player.id).set(player.toMap());
  }

  Future<void> updatePlayer(Player player) async {
    if (await _isGamerTagTaken(player.gamerTag, currentPlayerId: player.id)) {
      throw Exception('GamerTag is already taken.');
    }
    await _collection.doc(player.id).update(player.toMap());
  }

  Future<void> deletePlayer(String playerId) async {
    await _collection.doc(playerId).delete();
  }

  Future<Player?> getPlayerByUserId(String userId) async {
    final snapshot = await _collection.where('userId', isEqualTo: userId).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return Player.fromMap(doc.data(), doc.id);
    }
    return null;
  }

  Future<List<Player>> searchPlayers(String query) async {
    if (query.isEmpty) return [];
    // Check if query could be a user ID
    final userQuery = _collection.where('userId', isEqualTo: query).get();
    // Check if query could be a gamerTag
    final gamerTagQuery = _collection
        .where('gamerTag', isGreaterThanOrEqualTo: query)
        .where('gamerTag', isLessThan: query + 'z')
        .get();

    final results = await Future.wait([userQuery, gamerTagQuery]);
    final Set<Player> players = {};

    for (var snapshot in results) {
      for (var doc in snapshot.docs) {
        players.add(Player.fromMap(doc.data(), doc.id));
      }
    }
    return players.toList();
  }

  Future<List<Player>> getPlayers() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Player.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<Player>> getPlayersByIds(List<String> playerIds) async {
    if (playerIds.isEmpty) return [];
    final snapshot = await _collection.where(FieldPath.documentId, whereIn: playerIds).get();
    return snapshot.docs.map((doc) => Player.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<Player>> getPlayersByClan(String clanId) async {
    final snapshot = await _collection.where('clanId', isEqualTo: clanId).get();
    return snapshot.docs.map((doc) => Player.fromMap(doc.data(), doc.id)).toList();
  }

  Stream<List<Player>> getPlayersStream() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Player.fromSnapshot(doc)).toList();
    });
  }
}
