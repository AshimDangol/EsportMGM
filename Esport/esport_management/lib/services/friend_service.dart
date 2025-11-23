import 'package:cloud_firestore/cloud_firestore.dart';

class FriendService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _usersCollection;

  FriendService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance {
    _usersCollection = _firestore.collection('users');
  }

  Future<void> addFriend(String userId, String friendId) async {
    final batch = _firestore.batch();

    final userDoc = _usersCollection.doc(userId);
    batch.update(userDoc, {'friendIds': FieldValue.arrayUnion([friendId])});

    final friendDoc = _usersCollection.doc(friendId);
    batch.update(friendDoc, {'friendIds': FieldValue.arrayUnion([userId])});

    await batch.commit();
  }

  Future<void> removeFriend(String userId, String friendId) async {
    final batch = _firestore.batch();

    final userDoc = _usersCollection.doc(userId);
    batch.update(userDoc, {'friendIds': FieldValue.arrayRemove([friendId])});

    final friendDoc = _usersCollection.doc(friendId);
    batch.update(friendDoc, {'friendIds': FieldValue.arrayRemove([friendId])});

    await batch.commit();
  }
}
