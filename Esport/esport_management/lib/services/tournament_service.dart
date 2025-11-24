import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/match.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/services/db_exception.dart';

class TournamentService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _collection;

  TournamentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection('tournaments');
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> addTournament(Tournament tournament) async {
    await _collection.doc(tournament.id).set(tournament.toMap());
  }

  Future<void> updateTournament(Tournament tournament) async {
    await _collection.doc(tournament.id).update(tournament.toMap());
  }

  Future<void> deleteTournament(String tournamentId) async {
    await _collection.doc(tournamentId).delete();
  }

  Future<List<Tournament>> getAllTournaments() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Tournament.fromMap(doc.data()!, doc.id)).toList();
  }

  Future<Tournament?> getTournamentById(String tournamentId) async {
    final doc = await _collection.doc(tournamentId).get();
    if (doc.exists) {
      return Tournament.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<Tournament?> getTournamentByJoinCode(String joinCode) async {
    final snapshot = await _collection.where('joinCode', isEqualTo: joinCode).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return Tournament.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<Tournament>> getTournamentsForClan(String clanId) async {
    final snapshot = await _collection.where('registeredClanIds', arrayContains: clanId).get();
    return snapshot.docs.map((doc) => Tournament.fromMap(doc.data()!, doc.id)).toList();
  }

  Future<void> registerClan(String tournamentId, String clanId) async {
    await _collection.doc(tournamentId).update({
      'registeredClanIds': FieldValue.arrayUnion([clanId])
    });
  }

  Future<void> unregisterClanFromTournament(String tournamentId, String clanId) async {
    await _collection.doc(tournamentId).update({
      'registeredClanIds': FieldValue.arrayRemove([clanId]),
      'checkedInClanIds': FieldValue.arrayRemove([clanId]),
    });
  }

  Future<void> removePlayerFromTournament(String tournamentId, String playerId) async {
    await _collection.doc(tournamentId).update({
      'participatingPlayerIds': FieldValue.arrayRemove([playerId])
    });
  }

  Future<void> setClanCheckInStatus(String tournamentId, String clanId, bool isCheckedIn) async {
    final update = isCheckedIn
        ? {'checkedInClanIds': FieldValue.arrayUnion([clanId])}
        : {'checkedInClanIds': FieldValue.arrayRemove([clanId])};
    await _collection.doc(tournamentId).update(update);
  }

  Future<void> setParticipantStatus(String tournamentId, String userId, bool isParticipating) async {
    final update = isParticipating
        ? {'participatingPlayerIds': FieldValue.arrayUnion([userId])}
        : {'participatingPlayerIds': FieldValue.arrayRemove([userId])};
    await _collection.doc(tournamentId).update(update);
  }

  Future<void> updateSeeding(String tournamentId, Map<String, int> seeding) async {
    await _collection.doc(tournamentId).update({'seeding': seeding});
  }

  Future<void> scheduleMatch(String tournamentId, String matchId, DateTime dateTime) async {
    final tournament = await getTournamentById(tournamentId);
    if (tournament == null) return;

    final matches = tournament.matches;
    final matchIndex = matches.indexWhere((m) => m.id == matchId);
    if (matchIndex != -1) {
      matches[matchIndex] = matches[matchIndex].copyWith(scheduledTime: dateTime);
      await updateTournament(tournament.copyWith(matches: matches));
    }
  }

  Future<void> updateMatchScore(String tournamentId, String matchId, int clan1Score, int clan2Score) async {
    final tournament = await getTournamentById(tournamentId);
    if (tournament == null) throw DbException('Tournament not found.');

    final matchIndex = tournament.matches.indexWhere((m) => m.id == matchId);
    if (matchIndex == -1) throw DbException('Match not found.');

    final match = tournament.matches[matchIndex];
    String? winnerId;
    if (clan1Score > clan2Score) {
      winnerId = match.clan1Id;
    } else if (clan2Score > clan1Score) {
      winnerId = match.clan2Id;
    }

    final updatedMatch = match.copyWith(
      clan1Score: clan1Score,
      clan2Score: clan2Score,
      winnerId: winnerId,
      status: MatchStatus.completed,
    );

    var matches = List<Match>.from(tournament.matches);
    matches[matchIndex] = updatedMatch;

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

    if (matchIndexInCurrentRound % 2 == 0) {
      matches[nextMatchOverallIndex] = nextMatch.copyWith(clan1Id: completedMatch.winnerId);
    } else {
      matches[nextMatchOverallIndex] = nextMatch.copyWith(clan2Id: completedMatch.winnerId);
    }
  }

  Future<void> generateBracket(String tournamentId) async {
    final tournament = await getTournamentById(tournamentId);
    if (tournament == null) throw DbException('Tournament not found.');
    if (tournament.checkedInClanIds.length < 2) {
      throw DbException('Not enough checked-in clans.');
    }

    final clans = tournament.checkedInClanIds..shuffle();
    final matches = _generateSingleElimination(clans);
    final updatedTournament = tournament.copyWith(matches: matches);
    await updateTournament(updatedTournament);
  }

  List<Match> _generateSingleElimination(List<String> clans) {
    final List<Match> matches = [];
    final int numClans = clans.length;
    final int totalRounds = (log(numClans) / log(2)).ceil();
    int matchNumber = 1;

    List<String?> roundClans = List<String?>.from(clans);

    for (int round = 1; round <= totalRounds; round++) {
      final List<String?> nextRoundClans = [];
      for (int i = 0; i < roundClans.length; i += 2) {
        final clan1 = roundClans[i];
        final clan2 = (i + 1 < roundClans.length) ? roundClans[i + 1] : null;

        matches.add(Match(
          roundNumber: round,
          matchNumber: matchNumber++,
          clan1Id: clan1,
          clan2Id: clan2,
        ));
        nextRoundClans.add(null); // Placeholder for the winner
      }
      roundClans = nextRoundClans;
    }
    return matches;
  }
}
