import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/db_exception.dart';
import 'package:esport_mgm/services/mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode

class AuthService {
  final _db = MongoService().db;
  DbCollection get _collection {
    final collection = _db?.collection('users');
    if (collection == null) {
      throw DbException('Database not connected or collection not found.');
    }
    return collection;
  }

  // Basic session management using SharedPreferences
  static const String _sessionKey = 'currentUser';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // data being hashed
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> register(String email, String password) async {
    final existingUser = await _collection.findOne(where.eq('email', email));
    if (existingUser != null) {
      throw DbException('User with this email already exists.');
    }

    final hashedPassword = _hashPassword(password);
    final newUser = {
      'email': email,
      'password': hashedPassword, // Storing hashed password
      'role': UserRole.spectator.toString(),
    };

    final result = await _collection.insertOne(newUser);
    if (result.isSuccess) {
      final userMap = await _collection.findOne(where.eq('email', email));
      if (userMap != null) {
        final user = User.fromMap(userMap);
        await _saveSession(user.id);
        return user;
      }
    }
    return null;
  }

  Future<User?> login(String email, String password) async {
    final hashedPassword = _hashPassword(password);
    final userMap = await _collection.findOne(
      where.eq('email', email).eq('password', hashedPassword),
    );

    if (userMap != null) {
      final user = User.fromMap(userMap);
      await _saveSession(user.id);
      return user;
    }
    return null; // Invalid credentials
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_sessionKey);
    if (userId != null) {
      final userMap = await _collection.findOne(where.id(ObjectId.fromHexString(userId)));
      if (userMap != null) {
        return User.fromMap(userMap);
      }
    }
    return null;
  }
}
