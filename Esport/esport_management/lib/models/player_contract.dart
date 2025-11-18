import 'package:mongo_dart/mongo_dart.dart';

class PlayerContract {
  final ObjectId id;
  final String playerId;
  final String teamId;
  final DateTime startDate;
  final DateTime endDate;
  final double? salary;

  PlayerContract({
    ObjectId? id,
    required this.playerId,
    required this.teamId,
    required this.startDate,
    required this.endDate,
    this.salary,
  }) : id = id ?? ObjectId();

  factory PlayerContract.fromMap(Map<String, dynamic> map) {
    return PlayerContract(
      id: map['_id'] as ObjectId?,
      playerId: map['playerId'] as String,
      teamId: map['teamId'] as String,
      startDate: map['startDate'] as DateTime,
      endDate: map['endDate'] as DateTime,
      salary: (map['salary'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'playerId': playerId,
      'teamId': teamId,
      'startDate': startDate,
      'endDate': endDate,
      'salary': salary,
    };
  }
}
