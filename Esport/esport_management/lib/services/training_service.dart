import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/training.dart';

class TrainingService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _collection;

  TrainingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection('trainings');
  }

  Future<List<Training>> getTrainingsForClan(String clanId) async {
    final snapshot = await _collection.where('clanId', isEqualTo: clanId).get();
    return snapshot.docs.map((doc) => Training.fromMap(doc.id, doc.data())).toList();
  }
}
