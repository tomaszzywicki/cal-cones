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

  Future<List<WeightEntryModel>> getWeightEntriesForUser(int userId) async {
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
      AppLogger.error('WeightLogRepository.getWeightEntriesForUser error: $e');
      throw Exception('Failed to get weight entries for user: $e');
    }
  }
}
