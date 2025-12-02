// handles Meal and MealProduct data operations
import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';

class MealRepository {
  final LocalDatabaseService _databaseService;

  MealRepository(this._databaseService);

  Future<List<MealProductModel>> getMealProductsForDate(DateTime date, int userId) async {
    try {
      final db = await _databaseService.database;
      String dateString = date.toIso8601String().split('T').first;
      List<Map<String, dynamic>> result = await db.query(
        'meal_products',
        where: 'date(created_at) = ? AND user_id = ?',
        whereArgs: [dateString, userId],
      );
      return result.map((mealProductMap) => MealProductModel.fromMap(mealProductMap)).toList();
    } catch (e) {
      AppLogger.error('MealRepository.getMealProductsForDate error: $e');
      throw Exception('Failed to get meal products for date: $e');
    }
  }

  Future<int> addMealProduct(MealProductModel mealProduct, int userId) async {
    try {
      final db = await _databaseService.database;
      mealProduct.userId = userId;
      return await db.insert('meal_products', mealProduct.toMap());
    } catch (e) {
      AppLogger.error('MealRepository.addMealProduct error: $e');
      throw Exception('Failed to add meal product: $e');
    }
  }

  Future<int> updateMealProduct(MealProductModel mealProduct, int userId) async {
    try {
      final db = await _databaseService.database;
      return await db.update(
        'meal_products',
        mealProduct.toMap(),
        where: 'id = ? AND user_id = ?',
        whereArgs: [mealProduct.id, userId],
      );
    } catch (e) {
      AppLogger.error('MealRepository.updateMealProduct error: $e');
      throw Exception('Failed to update meal product: $e');
    }
  }

  Future<int> deleteMealProduct(int id, int userId) async {
    try {
      final db = await _databaseService.database;
      return await db.delete('meal_products', where: 'id = ? AND user_id = ?', whereArgs: [id, userId]);
    } catch (e) {
      AppLogger.error('MealRepository.deleteMealProduct error: $e');
      throw Exception('Failed to delete meal product: $e');
    }
  }
}
