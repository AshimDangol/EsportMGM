import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/team.dart';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _collection;

  TeamService() {
    _collection = _firestore.collection('teams');
  }

  Future<void> createTeam(Team team) async {
    await _collection.doc(team.id).set(team.toMap());
  }

  Future<Team?> getTeamById(String teamId) async {
    final doc = await _collection.doc(teamId).get();
    if (doc.exists) {
      return Team.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<Team>> getUserTeams(String userId) async {
    final snapshot = await _collection.where('managerId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Team.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<Team>> getTeamsByIds(List<String> teamIds) async {
    if (teamIds.isEmpty) return [];
    final snapshot = await _collection.where(FieldPath.documentId, whereIn: teamIds).get();
    return snapshot.docs.map((doc) => Team.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<Team>> getAllTeams() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Team.fromMap(doc.data(), doc.id)).toList();
  }
}
