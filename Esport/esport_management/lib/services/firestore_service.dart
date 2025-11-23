import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createUser(String uid, String email) async {
    return _firestore.collection('users').doc(uid).set({
      'email': email,
      'role': UserRole.admin.name, // Default role
      'theme': 'system',
    });
  }

  Stream<User?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return User.fromMap(snapshot.id, snapshot.data()!);
      }
      return null;
    });
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return _firestore.collection('users').doc(uid).get();
  }

  Future<List<User>> getUsers(List<String> uids) async {
    if (uids.isEmpty) return [];
    final snapshot = await _firestore.collection('users').where(FieldPath.documentId, whereIn: uids).get();
    return snapshot.docs.map((doc) => User.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<User>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => User.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<User>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final snapshot = await _firestore
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThan: query + 'z')
        .limit(10) // Limit results for performance
        .get();
    return snapshot.docs.map((doc) => User.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> updateUserTheme(String uid, String theme) async {
    return _firestore.collection('users').doc(uid).update({
      'theme': theme,
    });
  }

  Future<void> updateUserRole(String uid, UserRole role) async {
    return _firestore.collection('users').doc(uid).update({
      'role': role.name,
    });
  }
}
