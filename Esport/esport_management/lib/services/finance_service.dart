import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/revenue_agreement.dart';
import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/tournament.dart';

class FinanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _agreementsCollection;
  late final CollectionReference _walletsCollection;

  FinanceService() {
    _agreementsCollection = _firestore.collection('revenue_agreements');
    _walletsCollection = _firestore.collection('wallets');
  }

  Future<void> distributePrizePool(Tournament tournament, List<Team> finalRankings) async {
    if (tournament.prizeDistribution.isEmpty) return;

    for (int i = 0; i < finalRankings.length; i++) {
      final team = finalRankings[i];
      final rank = i + 1;

      final distributionRule = tournament.prizeDistribution.firstWhere(
        (d) => d.rank == rank,
        orElse: () => const PrizeDistribution(rank: -1),
      );

      if (distributionRule.rank != -1) {
        double totalWinnings = (distributionRule.percentage > 0)
            ? tournament.prizePool * (distributionRule.percentage / 100)
            : distributionRule.fixedAmount;

        final agreementDoc = await _agreementsCollection.doc(team.id).get();

        if (agreementDoc.exists) {
          final agreement = RevenueAgreement.fromMap(agreementDoc.data() as Map<String, dynamic>);
          await _splitWinnings(totalWinnings, team, agreement);
        } else {
          // If no agreement, give it all to the team's general wallet
          await _walletsCollection.doc(team.id).set({'balance': FieldValue.increment(totalWinnings)}, SetOptions(merge: true));
          print('Team ${team.name} has no revenue agreement. Paid \$${totalWinnings} to team wallet.');
        }
      }
    }
    print('Prize distribution complete.');
  }

  Future<void> _splitWinnings(double totalWinnings, Team team, RevenueAgreement agreement) async {
    // Organization's cut
    final orgCut = totalWinnings * (agreement.organizationPercentage / 100);
    await _walletsCollection.doc('org_${team.id}').set({'balance': FieldValue.increment(orgCut)}, SetOptions(merge: true));
    print('Paid \$${orgCut} to organization for Team ${team.name}');

    double playerPool = totalWinnings - orgCut;

    // Distribute remaining pool to players based on their percentages
    for (final entry in agreement.playerPercentages.entries) {
      final playerId = entry.key;
      final percentage = entry.value;
      final playerCut = playerPool * (percentage / 100);

      await _walletsCollection.doc(playerId).set({'balance': FieldValue.increment(playerCut)}, SetOptions(merge: true));
      print('Paid \$${playerCut} to player $playerId');
    }
  }

  Future<double> getWalletBalance(String walletId) async {
    final doc = await _walletsCollection.doc(walletId).get();
    if (doc.exists) {
      return (doc.data() as Map<String, dynamic>)['balance'] ?? 0.0;
    }
    return 0.0;
  }

  Future<void> saveAgreement(RevenueAgreement agreement) async {
    await _agreementsCollection.doc(agreement.teamId).set(agreement.toMap());
  }
}
