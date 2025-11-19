import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum SponsorshipLevel {
  platinum,
  gold,
  silver,
  bronze,
  partner,
}

@immutable
class Sponsor {
  final String id;
  final String name;
  final String? logoUrl;
  final String? website;
  final SponsorshipLevel level;
  final String description;
  final String creatorId;

  const Sponsor({
    required this.id,
    required this.name,
    this.logoUrl,
    this.website,
    this.level = SponsorshipLevel.partner,
    this.description = '',
    required this.creatorId,
  });

  factory Sponsor.fromMap(String id, Map<String, dynamic> data) {
    return Sponsor(
      id: id,
      name: data['name'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
      website: data['website'] as String?,
      level: SponsorshipLevel.values.firstWhere(
        (e) => e.name == data['level'],
        orElse: () => SponsorshipLevel.partner,
      ),
      description: data['description'] as String? ?? '',
      creatorId: data['creatorId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'website': website,
      'level': level.name,
      'description': description,
      'creatorId': creatorId,
    };
  }
}
