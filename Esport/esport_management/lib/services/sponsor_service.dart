import 'package:esport_mgm/models/sponsor.dart';
import 'package:mongo_dart/mongo_dart.dart';

class SponsorService {
  static const String _collection = 'sponsors';
  final Db _db;

  SponsorService(this._db);

  DbCollection get sponsorCollection => _db.collection(_collection);

  Future<void> addSponsor(Sponsor sponsor) async {
    await sponsorCollection.insert(sponsor.toMap());
  }

  Future<List<Sponsor>> getSponsors() async {
    final sponsorDocs = await sponsorCollection.find().toList();
    return sponsorDocs.map((doc) => Sponsor.fromMap(doc)).toList();
  }
}
