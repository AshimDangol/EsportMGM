import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/team.dart';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _teamsCollection;

  TeamService() {
    _teamsCollection = _firestore.collection('teams');
  }

  Future<void> addTeam(Team team) async {
    await _teamsCollection.add(team.toMap());
  }

  Future<List<Team>> getTeamsForTournament(String tournamentId) async {
    final snapshot = await _teamsCollection.where('tournamentId', isEqualTo: tournamentId).get();
    return snapshot.docs.map((doc) => Team.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<List<Team>> getAllTeams({Region? region}) async {
    Query query = _teamsCollection;
    if (region != null && region != Region.global) {
      query = query.where('region', isEqualTo: region.toString());
    }
    final snapshot = await query.orderBy('name').get();
    return snapshot.docs.map((doc) => Team.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }
}
