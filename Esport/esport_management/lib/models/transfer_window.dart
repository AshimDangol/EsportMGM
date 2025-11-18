import 'package:mongo_dart/mongo_dart.dart';

class TransferWindow {
  final ObjectId id;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  TransferWindow({
    ObjectId? id,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  }) : id = id ?? ObjectId();

  factory TransferWindow.fromMap(Map<String, dynamic> map) {
    return TransferWindow(
      id: map['_id'] as ObjectId?,
      startDate: map['startDate'] as DateTime,
      endDate: map['endDate'] as DateTime,
      isActive: map['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }
}
