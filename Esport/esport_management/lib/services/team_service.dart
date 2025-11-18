import 'package:esport_mgm/models/team.dart';
import 'package:mongo_dart/mongo_dart.dart';

class TeamService {
  static const String _collection = 'teams';
  final Db _db;

  TeamService(this._db);

  DbCollection get teamCollection => _db.collection(_collection);

  Future<void> addTeam(Team team) async {
    await teamCollection.insert(team.toMap());
  }

  Future<List<Team>> getTeamsForTournament(String tournamentId) async {
    final teamDocs = await teamCollection.find(where.eq('tournamentId', tournamentId)).toList();
    return teamDocs.map((doc) => Team.fromMap(doc)).toList();
  }

  Future<List<Team>> getAllTeams({Region? region}) async {
    final selector = region == null || region == Region.global
        ? where.sortBy('name')
        : where.eq('region', region.toString()).sortBy('name');

    final teamDocs = await teamCollection.find(selector).toList();
    return teamDocs.map((doc) => Team.fromMap(doc)).toList();
  }
}
