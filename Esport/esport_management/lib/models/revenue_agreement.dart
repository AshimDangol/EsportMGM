import 'package:mongo_dart/mongo_dart.dart';

class RevenueAgreement {
  final ObjectId id;
  final String teamId;
  final double organizationPercentage;
  final Map<String, double> playerPercentages; // PlayerID -> Percentage

  RevenueAgreement({
    required this.teamId,
    required this.organizationPercentage,
    required this.playerPercentages,
  }) : id = ObjectId();

  Map<String, dynamic> toMap() => {
        '_id': id,
        'teamId': teamId,
        'organizationPercentage': organizationPercentage,
        'playerPercentages': playerPercentages,
      };

  factory RevenueAgreement.fromMap(Map<String, dynamic> map) {
    return RevenueAgreement(
      teamId: map['teamId'] as String,
      organizationPercentage: (map['organizationPercentage'] as num).toDouble(),
      playerPercentages: (map['playerPercentages'] as Map).cast<String, double>(),
    )..id.id = map['_id'] as ObjectId;
  }
}
