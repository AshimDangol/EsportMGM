import 'package:esport_mgm/models/player_profile.dart';
import 'package:esport_mgm/services/db_exception.dart';
import 'package:esport_mgm/services/mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PlayerProfileService {
  final _db = MongoService().db;
  DbCollection get _collection {
    final collection = _db?.collection('player_profiles');
    if (collection == null) {
      throw DbException('Database not connected or collection not found.');
    }
    return collection;
  }

  Future<void> createProfile(PlayerProfile profile) async {
    try {
      final result = await _collection.insertOne(profile.toMap());
      if (!result.isSuccess) {
        throw DbException('Failed to create profile.');
      }
    } catch (e) {
      throw DbException('Error creating profile: $e');
    }
  }

  Future<PlayerProfile?> getProfileByUserId(String userId) async {
    try {
      final map = await _collection.findOne(where.eq('userId', userId));
      if (map != null) {
        return PlayerProfile.fromMap(map);
      }
      return null;
    } catch (e) {
      throw DbException('Error fetching profile: $e');
    }
  }

  Future<void> updateProfile(PlayerProfile profile) async {
    try {
      final result = await _collection.replaceOne(
        where.eq('_id', profile.id),
        profile.toMap(),
      );
      if (!result.isSuccess) {
        throw DbException('Failed to update profile.');
      }
    } catch (e) {
      throw DbException('Error updating profile: $e');
    }
  }
}
