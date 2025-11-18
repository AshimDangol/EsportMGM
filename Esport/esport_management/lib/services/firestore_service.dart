import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createUser(String uid, String email) async {
    return _firestore.collection('users').doc(uid).set({
      'email': email,
      'role': 'spectator',
    });
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return _firestore.collection('users').doc(uid).get();
  }

  Future<void> addTeam(Map<String, dynamic> teamData) async {
    await _firestore.collection('teams').add(teamData);
  }

  Future<void> addPlayer(Map<String, dynamic> playerData) async {
    await _firestore.collection('players').add(playerData);
  }

  Future<void> addSpectator(Map<String, dynamic> spectatorData) async {
    await _firestore.collection('spectators').add(spectatorData);
  }

  Future<void> purchaseTicket(Map<String, dynamic> ticketData) async {
    await _firestore.collection('tickets').add(ticketData);
  }
}
