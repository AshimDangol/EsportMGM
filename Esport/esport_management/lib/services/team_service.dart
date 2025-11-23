import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/team.dart';

class TeamService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _teamsCollection;
  late final CollectionReference<Map<String, dynamic>> _clansCollection;

  TeamService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _teamsCollection = _firestore.collection('teams');
    _clansCollection = _firestore.collection('clans');
  }

  Future<void> createTeam(Team team) async {
    final batch = _firestore.batch();
    final teamRef = _teamsCollection.doc(team.id);
    batch.set(teamRef, team.toMap());

    final clanRef = _clansCollection.doc(team.clanId);
    batch.update(clanRef, {
      'teamIds': FieldValue.arrayUnion([team.id])
    });

    await batch.commit();
  }

  Future<void> updateTeam(Team team) async {
    await _teamsCollection.doc(team.id).update(team.toMap());
  }

  Future<Team?> getTeamById(String teamId) async {
    final doc = await _teamsCollection.doc(teamId).get();
    if (doc.exists) {
      return Team.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<Team>> getAllTeams() async {
    final snapshot = await _teamsCollection.get();
    return snapshot.docs.map((doc) => Team.fromMap(doc.data()!, doc.id)).toList();
  }

  Future<List<Team>> getTeamsForClan(String clanId) async {
    final snapshot = await _teamsCollection.where('clanId', isEqualTo: clanId).get();
    return snapshot.docs.map((doc) => Team.fromMap(doc.data(), doc.id)).toList();
  }
}
