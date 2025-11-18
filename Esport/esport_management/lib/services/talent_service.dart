import 'package:esport_mgm/models/talent.dart';
import 'package:mongo_dart/mongo_dart.dart';

class TalentService {
  static const String _collection = 'talent';
  final Db _db;

  TalentService(this._db);

  DbCollection get talentCollection => _db.collection(_collection);

  Future<void> addTalent(Talent talent) async {
    await talentCollection.insert(talent.toMap());
  }

  Future<List<Talent>> getTalent() async {
    final talentDocs = await talentCollection.find().toList();
    return talentDocs.map((doc) => Talent.fromMap(doc)).toList();
  }
}
