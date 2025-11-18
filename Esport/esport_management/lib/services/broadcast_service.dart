import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/broadcast_schedule.dart';

class BroadcastService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _scheduleCollection;

  BroadcastService() {
    _scheduleCollection = _firestore.collection('broadcast_schedules');
  }

  Future<void> addScheduleItem(BroadcastScheduleItem item) async {
    await _scheduleCollection.add(item.toMap());
  }

  Future<List<BroadcastScheduleItem>> getScheduleForTournament(String tournamentId) async {
    final snapshot = await _scheduleCollection
        .where('tournamentId', isEqualTo: tournamentId)
        .orderBy('startTime')
        .get();
    return snapshot.docs
        .map((doc) => BroadcastScheduleItem.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateScheduleItem(BroadcastScheduleItem item) async {
    await _scheduleCollection.doc(item.id.toHexString()).update(item.toMap());
  }

  Future<void> deleteScheduleItem(String itemId) async {
    await _scheduleCollection.doc(itemId).delete();
  }
}
