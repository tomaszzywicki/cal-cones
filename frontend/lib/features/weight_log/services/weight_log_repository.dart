import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';

class WeightLogRepository {
  final LocalDatabaseService _databaseService;

  WeightLogRepository(this._databaseService);

  Future<int> addWeightEntry(WeightEntryModel weightEntry, int userId) async {
    try {
      final db = await _databaseService.database;
      weightEntry.userId = userId;
      return await db.insert('weight_entries', weightEntry.toMap());
    } catch (e) {
      AppLogger.error('WeightLogRepository.addWeightEntry error: $e');
      throw Exception('Failed to add weight entry: $e');
    }
  }

  Future<void> deleteWeightEntry(WeightEntryModel weightEntry) async {
    try {
      final db = await _databaseService.database;
      await db.delete('weight_entries', where: 'id = ?', whereArgs: [weightEntry.id]);
    } catch (e) {
      AppLogger.error('WeightLogRepository.deleteWeightEntry error: $e');
      throw Exception('Failed to delete weight entry: $e');
    }
  }

  Future<List<WeightEntryModel>> getWeightEntries(int userId) async {
    try {
      final db = await _databaseService.database;
      List<Map<String, dynamic>> result = await db.query(
        'weight_entries',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
      return result.map((weightEntryMap) => WeightEntryModel.fromMap(weightEntryMap)).toList();
    } catch (e) {
      AppLogger.error('WeightLogRepository.getWeightEntries error: $e');
      throw Exception('Failed to get weight entries: $e');
    }
  }

  Future<WeightEntryModel?> getLatestWeightEntry(int userId) async {
    try {
      final db = await _databaseService.database;
      List<Map<String, dynamic>> result = await db.query(
        'weight_entries',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
        limit: 1,
      );
      if (result.isNotEmpty) {
        return WeightEntryModel.fromMap(result.first);
      } else {
        return null;
      }
    } catch (e) {
      AppLogger.error('WeightLogRepository.getLatestWeightEntry error: $e');
      throw Exception('Failed to get latest weight entry: $e');
    }
  }
}
