import 'package:mongo_dart/mongo_dart.dart';

enum TalentRole {
  commentator,
  host,
  analyst,
  observer,
}

class Talent {
  final ObjectId id;
  final String name;
  final TalentRole role;
  final String contactEmail;

  Talent({
    required this.name,
    required this.role,
    required this.contactEmail,
  }) : id = ObjectId();

  Map<String, dynamic> toMap() => {
        '_id': id,
        'name': name,
        'role': role.toString(),
        'contactEmail': contactEmail,
      };

  factory Talent.fromMap(Map<String, dynamic> map) {
    return Talent(
      name: map['name'] as String,
      role: TalentRole.values.firstWhere((e) => e.toString() == map['role'], orElse: () => TalentRole.commentator),
      contactEmail: map['contactEmail'] as String,
    )..id.id = map['_id'] as ObjectId;
  }
}
