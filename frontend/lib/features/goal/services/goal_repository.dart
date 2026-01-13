import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/goal/data/goal_model.dart';

class GoalRepository {
  final LocalDatabaseService _databaseService;

  GoalRepository(this._databaseService);

  Future<int> addGoal(GoalModel goal, int userId) async {
    try {
      final db = await _databaseService.database;
      goal.userId = userId;
      return await db.insert('goals', goal.toMap());
    } catch (e) {
      AppLogger.error('GoalRepository.addGoal error: $e');
      throw Exception('Failed to add goal: $e');
    }
  }

  Future<void> deleteGoal(GoalModel goal) async {
    try {
      final db = await _databaseService.database;
      await db.delete('goals', where: 'id = ?', whereArgs: [goal.id]);
    } catch (e) {
      AppLogger.error('GoalRepository.deleteGoal error: $e');
      throw Exception('Failed to delete goal: $e');
    }
  }

  Future<List<GoalModel>> getGoals(int userId) async {
    try {
      final db = await _databaseService.database;
      List<Map<String, dynamic>> result = await db.query(
        'goals',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      return result.map((goalMap) => GoalModel.fromMap(goalMap)).toList();
    } catch (e) {
      AppLogger.error('GoalRepository.getGoals error: $e');
      throw Exception('Failed to get goals: $e');
    }
  }
}
