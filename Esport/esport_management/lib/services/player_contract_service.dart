import 'package:esport_mgm/models/player_contract.dart';
import 'package:esport_mgm/services/db_exception.dart';
import 'package:esport_mgm/services/mongo_service.dart';
import 'package:esport_mgm/services/transfer_window_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PlayerContractService {
  final _db = MongoService().db;
  final _transferWindowService = TransferWindowService();

  DbCollection get _collection {
    final collection = _db?.collection('player_contracts');
    if (collection == null) {
      throw DbException('Database not connected or collection not found.');
    }
    return collection;
  }

  Future<void> createContract(PlayerContract contract) async {
    final activeWindow = await _transferWindowService.getActiveTransferWindow();
    if (activeWindow == null) {
      throw AuthException('The transfer window is currently closed.');
    }

    try {
      final result = await _collection.insertOne(contract.toMap());
      if (!result.isSuccess) {
        throw DbException('Failed to create contract.');
      }
    } catch (e) {
      throw DbException('Error creating contract: $e');
    }
  }

  Future<List<PlayerContract>> getContractsForTeam(String teamId) async {
    try {
      final contractMaps = await _collection.find(where.eq('teamId', teamId)).toList();
      return contractMaps.map((map) => PlayerContract.fromMap(map)).toList();
    } catch (e) {
      throw DbException('Error fetching contracts: $e');
    }
  }

  Future<void> updateContract(PlayerContract contract) async {
    final activeWindow = await _transferWindowService.getActiveTransferWindow();
    if (activeWindow == null) {
      throw AuthException('The transfer window is currently closed.');
    }

    try {
      final result = await _collection.replaceOne(
        where.eq('_id', contract.id),
        contract.toMap(),
      );
      if (!result.isSuccess) {
        throw DbException('Failed to update contract.');
      }
    } catch (e) {
      throw DbException('Error updating contract: $e');
    }
  }

  Future<void> deleteContract(ObjectId contractId) async {
    final activeWindow = await _transferWindowService.getActiveTransferWindow();
    if (activeWindow == null) {
      throw AuthException('The transfer window is currently closed.');
    }
    
    try {
      final result = await _collection.deleteOne(where.eq('_id', contractId));
      if (!result.isSuccess) {
        throw DbException('Failed to delete contract.');
      }
    } catch (e) {
      throw DbException('Error deleting contract: $e');
    }
  }
}
