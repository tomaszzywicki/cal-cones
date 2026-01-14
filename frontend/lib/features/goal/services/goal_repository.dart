import 'package:sqflite/sqflite.dart';
import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/features/goal/data/goal_model.dart';

class GoalRepository {
  final LocalDatabaseService _dbService;
  final String tableName = 'user_goals';

  GoalRepository(this._dbService);

  Future<Database> get _db async => await _dbService.database;

  /// Pobiera aktualnie aktywny cel (taki, który nie ma daty zakończenia)
  Future<GoalModel?> getActiveGoal(int userId) async {
    final db = await _db;
    final result = await db.query(
      tableName, // Upewnij się, że tak nazwałeś tabelę w tables.dart
      where: 'user_id = ? AND is_current = 1', // Lub sprawdzamy end_date IS NULL
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return GoalModel.fromJson(result.first);
    }
    return null;
  }

  /// Tworzy nowy cel
  Future<int> createGoal(GoalModel goal) async {
    final db = await _db;
    return await db.insert(tableName, goal.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Aktualizuje cel (np. ustawia end_date przy zamykaniu)
  Future<int> updateGoal(GoalModel goal) async {
    final db = await _db;
    return await db.update(tableName, goal.toJson(), where: 'id = ?', whereArgs: [goal.id]);
  }

  /// Pobiera historię celów (opcjonalne, do wykresów)
  Future<List<GoalModel>> getGoalHistory(String userId) async {
    final db = await _db;
    final result = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
    );

    return result.map((e) => GoalModel.fromJson(e)).toList();
  }
}
