import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserService {
  final MongoService _mongoService = MongoService();

  Future<UserProfile?> getUserByUid(String uid) async {
    final db = _mongoService.db;
    if (db == null) throw Exception('Database not connected');

    final usersCollection = db.collection('users');
    final userMap = await usersCollection.findOne(where.eq('uid', uid));

    if (userMap != null) {
      return UserProfile.fromMap(userMap);
    } else {
      return null;
    }
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    final db = _mongoService.db;
    if (db == null) throw Exception('Database not connected');

    final usersCollection = db.collection('users');
    await usersCollection.update(
      where.eq('uid', userProfile.uid),
      userProfile.toMap(),
    );
  }
}
