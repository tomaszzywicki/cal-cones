import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/product/data/product_model.dart';

class MealRepository {
  final LocalDatabaseService _databaseService;

  MealRepository(this._databaseService);

  Future<MealProductModel> addMealProduct(MealProductModel mealProduct, int userId) async {
    mealProduct.userId = userId;
    try {
      final db = await _databaseService.database;

      final id = await db.insert('meal_products', mealProduct.toMap());
      return mealProduct.copyWith(id: id);
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

  Future<int> deleteMealProduct(MealProductModel mealProduct, int userId) async {
    try {
      final db = await _databaseService.database;
      return await db.delete(
        'meal_products',
        where: 'id = ? AND user_id = ?',
        whereArgs: [mealProduct.id, userId],
      );
    } catch (e) {
      AppLogger.error('MealRepository.deleteMealProduct error: $e');
      throw Exception('Failed to delete meal product: $e');
    }
  }

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

  Future<void> markAsSynced(String uuid) async {
    try {
      final db = await _databaseService.database;
      await db.update('meal_products', {'is_synced': 1}, where: 'uuid = ?', whereArgs: [uuid]);
    } catch (e) {
      AppLogger.error('MealRepository.markAsSynced error: $e');
      throw Exception('Failed to mark meal product as synced: $e');
    }
  }

  Future<void> insertFromServer(MealProductModel mealProduct, int userId) async {
    final db = await _databaseService.database;

    final mealProductToInsert = mealProduct.copyWith(userId: userId, isSynced: true);

    await db.insert('meal_products', mealProductToInsert.toMap());
  }

  Future<void> updateFromServer(MealProductModel mealProduct) async {
    final db = await _databaseService.database;

    final mealProductToUpdate = mealProduct.copyWith(isSynced: true);

    await db.update(
      'meal_products',
      mealProductToUpdate.toMap(),
      where: 'uuid = ?',
      whereArgs: [mealProductToUpdate.uuid],
    );
  }

  Future<MealProductModel?> getByUuid(String uuid) async {
    final db = await _databaseService.database;
    final result = await db.query('meal_products', where: 'uuid = ?', whereArgs: [uuid]);
    if (result.isEmpty) return null;
    return MealProductModel.fromMap(result.first);
  }
}
