import 'dart:math';

import 'package:collection/collection.dart';
import 'package:esport_mgm/models/match.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/services/db_exception.dart';
import 'package:esport_mgm/services/mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class TournamentService {
  final _db = MongoService().db;
  DbCollection get _collection {
    // ... (collection getter)
  }

  // ... (create, get, update, delete tournament methods)

  Future<void> generateBracket(String tournamentId) async {
    final tournament = await getTournamentById(tournamentId);
    if (tournament == null) throw DbException('Tournament not found.');
    if (tournament.checkedInTeamIds.length < 2) {
      throw DbException('Not enough checked-in teams.');
    }

    // ... (team shuffling/seeding logic)

    final matches = _generateSingleElimination(teams);
    final updatedTournament = tournament.copyWith(matches: matches);
    await updateTournament(updatedTournament);
  }

  List<Match> _generateSingleElimination(List<String> teams) {
    final List<Match> matches = [];
    final int numTeams = teams.length;
    final int totalRounds = (log(numTeams) / log(2)).ceil();
    int matchNumber = 1;

    List<String?> roundTeams = List<String?>.from(teams);

    for (int round = 1; round <= totalRounds; round++) {
      final List<String?> nextRoundTeams = [];
      for (int i = 0; i < roundTeams.length; i += 2) {
        final team1 = roundTeams[i];
        final team2 = (i + 1 < roundTeams.length) ? roundTeams[i + 1] : null;

        matches.add(Match(
          roundNumber: round,
          matchNumber: matchNumber++,
          team1Id: team1,
          team2Id: team2,
        ));
        nextRoundTeams.add(null); // Placeholder for the winner
      }
      roundTeams = nextRoundTeams;
    }
    return matches;
  }

  Future<void> updateMatchScore(String tournamentId, ObjectId matchId, int team1Score, int team2Score) async {
    final tournament = await getTournamentById(tournamentId);
    if (tournament == null) throw DbException('Tournament not found.');

    final matchIndex = tournament.matches.indexWhere((m) => m.id == matchId);
    if (matchIndex == -1) throw DbException('Match not found.');

    final match = tournament.matches[matchIndex];
    String? winnerId;
    if (team1Score > team2Score) {
      winnerId = match.team1Id;
    } else if (team2Score > team1Score) {
      winnerId = match.team2Id;
    }

    final updatedMatch = match.copyWith(
      team1Score: team1Score,
      team2Score: team2Score,
      winnerId: winnerId,
      status: MatchStatus.completed,
    );

    var matches = List<Match>.from(tournament.matches);
    matches[matchIndex] = updatedMatch;

    // Advance the winner to the next round
    if (winnerId != null) {
      _advanceWinner(matches, updatedMatch);
    }

    final updatedTournament = tournament.copyWith(matches: matches);
    await updateTournament(updatedTournament);
  }

  void _advanceWinner(List<Match> matches, Match completedMatch) {
    final int currentRound = completedMatch.roundNumber;
    final int nextRound = currentRound + 1;

    // Find the match in the next round that this winner feeds into
    final int matchIndexInCurrentRound = matches
        .where((m) => m.roundNumber == currentRound)
        .toList()
        .indexWhere((m) => m.matchNumber == completedMatch.matchNumber);

    final int nextMatchIndexInNextRound = matchIndexInCurrentRound ~/ 2;

    final nextMatch = matches
        .where((m) => m.roundNumber == nextRound)
        .toList()[nextMatchIndexInNextRound];

    final nextMatchOverallIndex = matches.indexWhere((m) => m.id == nextMatch.id);

    // Place the winner in the appropriate slot (team1 or team2)
    if (matchIndexInCurrentRound % 2 == 0) {
      matches[nextMatchOverallIndex] = nextMatch.copyWith(team1Id: completedMatch.winnerId);
    } else {
      matches[nextMatchOverallIndex] = nextMatch.copyWith(team2Id: completedMatch.winnerId);
    }
  }

  // ... (other service methods)
}
