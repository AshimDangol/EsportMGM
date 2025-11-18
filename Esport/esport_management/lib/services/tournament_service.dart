import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:esport_mgm/models/match.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/services/db_exception.dart';

class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _collection;

  TournamentService() {
    _collection = _firestore.collection('tournaments');
  }

  Future<List<Tournament>> getAllTournaments() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Tournament.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Stream<List<Tournament>> snapshots() {
    return _collection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Tournament.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> createTournament(Tournament tournament) async {
    await _collection.add(tournament.toMap());
  }

  Future<Tournament?> getTournamentById(String tournamentId) async {
    final doc = await _collection.doc(tournamentId).get();
    if (doc.exists) {
      return Tournament.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> updateTournament(Tournament tournament) async {
    await _collection.doc(tournament.id).update(tournament.toMap());
  }

  Future<void> deleteTournament(String tournamentId) async {
    await _collection.doc(tournamentId).delete();
  }

  Future<void> generateBracket(String tournamentId) async {
    final tournament = await getTournamentById(tournamentId);
    if (tournament == null) throw DbException('Tournament not found.');
    if (tournament.checkedInTeamIds.length < 2) {
      throw DbException('Not enough checked-in teams.');
    }

    final teams = tournament.checkedInTeamIds..shuffle();

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

  Future<void> updateMatchScore(String tournamentId, String matchId, int team1Score, int team2Score) async {
    final tournament = await getTournamentById(tournamentId);
    if (tournament == null) throw DbException('Tournament not found.');

    final matchIndex = tournament.matches.indexWhere((m) => m.id.toHexString() == matchId);
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

    final currentRoundMatches = matches.where((m) => m.roundNumber == currentRound).toList();
    final matchIndexInCurrentRound = currentRoundMatches.indexWhere((m) => m.matchNumber == completedMatch.matchNumber);

    if (matchIndexInCurrentRound == -1) return;

    final nextMatchIndexInNextRound = matchIndexInCurrentRound ~/ 2;

    final nextRoundMatches = matches.where((m) => m.roundNumber == nextRound).toList();
    if (nextMatchIndexInNextRound >= nextRoundMatches.length) return;

    final nextMatch = nextRoundMatches[nextMatchIndexInNextRound];
    final nextMatchOverallIndex = matches.indexWhere((m) => m.id == nextMatch.id);

    if (nextMatchOverallIndex == -1) return;

    // Place the winner in the appropriate slot (team1 or team2)
    if (matchIndexInCurrentRound % 2 == 0) {
      matches[nextMatchOverallIndex] = nextMatch.copyWith(team1Id: completedMatch.winnerId);
    } else {
      matches[nextMatchOverallIndex] = nextMatch.copyWith(team2Id: completedMatch.winnerId);
    }
  }
}
