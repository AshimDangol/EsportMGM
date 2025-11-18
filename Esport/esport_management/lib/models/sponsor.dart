import 'package:mongo_dart/mongo_dart.dart';

class Sponsor {
  final ObjectId id;
  final String name;
  final String contactPerson;
  final String contactEmail;
  final DateTime contractStartDate;
  final DateTime contractEndDate;
  final String sponsorshipLevel;
  final double sponsorshipAmount;
  final String? brandAssetUrl; // URL to a ZIP file or cloud folder

  Sponsor({
    required this.name,
    required this.contactPerson,
    required this.contactEmail,
    required this.contractStartDate,
    required this.contractEndDate,
    required this.sponsorshipLevel,
    required this.sponsorshipAmount,
    this.brandAssetUrl,
  }) : id = ObjectId();

  Map<String, dynamic> toMap() => {
        '_id': id,
        'name': name,
        'contactPerson': contactPerson,
        'contactEmail': contactEmail,
        'contractStartDate': contractStartDate,
        'contractEndDate': contractEndDate,
        'sponsorshipLevel': sponsorshipLevel,
        'sponsorshipAmount': sponsorshipAmount,
        'brandAssetUrl': brandAssetUrl,
      };

  factory Sponsor.fromMap(Map<String, dynamic> map) {
    return Sponsor(
      name: map['name'] as String,
      contactPerson: map['contactPerson'] as String,
      contactEmail: map['contactEmail'] as String,
      contractStartDate: map['contractStartDate'] as DateTime,
      contractEndDate: map['contractEndDate'] as DateTime,
      sponsorshipLevel: map['sponsorshipLevel'] as String,
      sponsorshipAmount: (map['sponsorshipAmount'] as num).toDouble(),
      brandAssetUrl: map['brandAssetUrl'] as String?,
    )..id.id = map['_id'] as ObjectId;
  }
}
