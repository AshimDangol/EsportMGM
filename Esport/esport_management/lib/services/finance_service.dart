import 'package:esport_mgm/models/revenue_agreement.dart';
import 'package:esport_mgm/models/team.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:mongo_dart/mongo_dart.dart';

class FinanceService {
  final Db _db;

  // In a real app, these would be separate collections for wallets
  final Map<String, double> _wallets = {}; // Key: teamId or playerId

  FinanceService(this._db);

  DbCollection get agreementsCollection => _db.collection('revenue_agreements');

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

        final agreementDoc = await agreementsCollection.findOne(where.eq('teamId', team.id.toHexString()));

        if (agreementDoc != null) {
          final agreement = RevenueAgreement.fromMap(agreementDoc);
          await _splitWinnings(totalWinnings, team, agreement);
        } else {
          // If no agreement, give it all to the team's general wallet
          _wallets.update(team.id.toHexString(), (v) => v + totalWinnings, ifAbsent: () => totalWinnings);
          print('Team ${team.name} has no revenue agreement. Paid $$totalWinnings to team wallet.');
        }
      }
    }
    print('Prize distribution complete.');
  }

  Future<void> _splitWinnings(double totalWinnings, Team team, RevenueAgreement agreement) async {
    // Organization's cut
    final orgCut = totalWinnings * (agreement.organizationPercentage / 100);
    _wallets.update('org_${team.id.toHexString()}', (v) => v + orgCut, ifAbsent: () => orgCut);
    print('Paid $$orgCut to organization for Team ${team.name}');

    double playerPool = totalWinnings - orgCut;

    // Distribute remaining pool to players based on their percentages
    for (final entry in agreement.playerPercentages.entries) {
      final playerId = entry.key;
      final percentage = entry.value;
      final playerCut = playerPool * (percentage / 100);

      _wallets.update(playerId, (v) => v + playerCut, ifAbsent: () => playerCut);
      print('Paid $$playerCut to player $playerId');
    }
  }

  double getWalletBalance(String walletId) {
    return _wallets[walletId] ?? 0.0;
  }

  Future<void> saveAgreement(RevenueAgreement agreement) async {
    await agreementsCollection.replaceOne(
      where.eq('teamId', agreement.teamId),
      agreement.toMap(),
      upsert: true,
    );
  }
}
