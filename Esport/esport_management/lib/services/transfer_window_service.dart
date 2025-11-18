import 'package:esport_mgm/models/transfer_window.dart';
import 'package:esport_mgm/services/db_exception.dart';
import 'package:esport_mgm/services/mongo_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class TransferWindowService {
  final _db = MongoService().db;
  DbCollection get _collection {
    final collection = _db?.collection('transfer_windows');
    if (collection == null) {
      throw DbException('Database not connected or collection not found.');
    }
    return collection;
  }

  Future<void> createTransferWindow(TransferWindow window) async {
    try {
      final result = await _collection.insertOne(window.toMap());
      if (!result.isSuccess) {
        throw DbException('Failed to create transfer window.');
      }
    } catch (e) {
      throw DbException('Error creating transfer window: $e');
    }
  }

  Future<TransferWindow?> getActiveTransferWindow() async {
    try {
      final now = DateTime.now().toUtc();
      final map = await _collection.findOne(
        where
            .eq('isActive', true)
            .and(where.lte('startDate', now))
            .and(where.gte('endDate', now)),
      );
      if (map != null) {
        return TransferWindow.fromMap(map);
      }
      return null;
    } catch (e) {
      throw DbException('Error fetching active transfer window: $e');
    }
  }

    Future<List<TransferWindow>> getAllTransferWindows() async {
    try {
      final maps = await _collection.find().toList();
      return maps.map((map) => TransferWindow.fromMap(map)).toList();
    } catch (e) {
      throw DbException('Error fetching transfer windows: $e');
    }
  }

  Future<void> updateTransferWindow(TransferWindow window) async {
    try {
      final result = await _collection.replaceOne(
        where.eq('_id', window.id),
        window.toMap(),
      );
      if (!result.isSuccess) {
        throw DbException('Failed to update transfer window.');
      }
    } catch (e) {
      throw DbException('Error updating transfer window: $e');
    }
  }
}
