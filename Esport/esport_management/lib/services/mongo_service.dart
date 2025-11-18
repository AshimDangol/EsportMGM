import 'package:esport_mgm/models/announcement.dart';
import 'package:esport_mgm/models/tournament.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  Db? _db;

  Future<void> connect() async {
    final connectionString = dotenv.env['MONGODB_CONNECTION_STRING'];
    if (connectionString == null || connectionString == 'YOUR_MONGODB_CONNECTION_STRING') {
      throw Exception('MONGODB_CONNECTION_STRING is not set in .env file. Please add it.');
    }
    _db = await Db.create(connectionString);
    await _db!.open();
  }

  Db? get db => _db;

  Future<void> close() async {
    await _db?.close();
  }

  //############ ANNOUNCEMENT METHODS ############

  Future<void> createAnnouncement(String title, String content) async {
    if (_db == null) throw Exception('Database not connected');
    final collection = _db!.collection('announcements');
    await collection.insert({
      'title': title,
      'content': content,
      'createdAt': DateTime.now(),
    });
  }

  Future<List<Announcement>> getAnnouncements() async {
    if (_db == null) throw Exception('Database not connected');
    final collection = _db!.collection('announcements');
    final announcements = await collection.find(where.sortBy('createdAt', descending: true)).toList();
    return announcements.map((doc) => Announcement.fromMap(doc)).toList();
  }

  //############ TOURNAMENT METHODS ############

  Future<List<Tournament>> getTournaments() async {
    if (_db == null) throw Exception('Database not connected');
    final collection = _db!.collection('tournaments');
    final tournaments = await collection.find().toList();
    return tournaments.map((doc) => Tournament.fromMap(doc)).toList();
  }
}
