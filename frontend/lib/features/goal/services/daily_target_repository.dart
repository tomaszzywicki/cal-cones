import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/features/goal/data/daily_target_model.dart';

class DailyTargetRepository {
  final LocalDatabaseService _databaseService;

  DailyTargetRepository(this._databaseService);

  Future<String?> getLastEntryDate(int userId) async {
    try {
      final db = await _databaseService.database;
      List<Map<String, dynamic>> result = await db.query(
        'daily_targets',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
        limit: 1,
      );
      if (result.isNotEmpty) {
        return result.first['date'] as String;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get last daily target entry date: $e');
    }
  }

  Future<void> saveDailyTarget(DailyTargetModel targetModel) async {
    try {
      final db = await _databaseService.database;
      await db.insert('daily_targets', targetModel.toMap());
    } catch (e) {
      throw Exception('Failed to save daily target: $e');
    }
  }

  Future<DailyTargetModel?> getDailyTargetForDate(int userId, String date) async {
    try {
      final db = await _databaseService.database;
      List<Map<String, dynamic>> result = await db.query(
        'daily_targets',
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, date],
        limit: 1,
      );
      if (result.isNotEmpty) {
        return DailyTargetModel.fromMap(result.first);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get daily target for date: $e');
    }
  }
}
