import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/player_stats.dart';

class PlayerStatsService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _collection;

  PlayerStatsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection('player_stats');
  }

  // Gets a player's stats. If they don't exist, returns a fresh object.
  Future<PlayerStats> getPlayerStats(String playerId) async {
    final doc = await _collection.doc(playerId).get();
    if (doc.exists) {
      return PlayerStats.fromMap(doc.id, doc.data()!);
    }
    return PlayerStats.initial(playerId); // Return a default object if none exists
  }

  // Updates stats for multiple players after a match.
  // This uses a batch write for efficiency.
  Future<void> updateStatsForPlayers(Map<String, PlayerStats> statsMap) async {
    final batch = _firestore.batch();

    statsMap.forEach((playerId, stats) {
      final docRef = _collection.doc(playerId);
      batch.set(docRef, stats.toMap(), SetOptions(merge: true));
    });

    await batch.commit();
  }
}
