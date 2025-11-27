// handles Meal and MealProduct data operations
import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';

class MealRepository {
  final LocalDatabaseService _databaseService;

  MealRepository(this._databaseService);

  // ========= Meals part =============

  Future<List<MealModel>> getMealsForUser(int userId) async {
    final db = await _databaseService.database;
    final mealMaps = await db.query('meals', where: 'user_id = ?', whereArgs: [userId]);
    return mealMaps.map((map) => MealModel.fromJson(map)).toList();
  }

  Future<int> addMeal(MealModel meal, int userId) async {
    final db = await _databaseService.database;
    meal.userId ??= userId;
    return await db.insert('meals', meal.toJson());
  }

  Future<int> updateMeal(MealModel meal) async {
    final db = await _databaseService.database;
    return await db.update('meals', meal.toJson(), where: 'id = ?', whereArgs: [meal.id]);
  }

  Future<int> deleteMeal(int mealId) async {
    final db = await _databaseService.database;
    return await db.delete('meals', where: 'id = ?', whereArgs: [mealId]);
  }

  Future<List<MealModel>> getMealsByDateRange(int userId, DateTime startDate, DateTime endDate) async {
    final db = await _databaseService.database;

    final mealMaps = await db.query(
      'meals',
      where: 'user_id = ? AND consumed_at >= ? AND consumed_at < ?',
      whereArgs: [userId, startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'consumed_at DESC',
    );

    return mealMaps.map((map) => MealModel.fromMap(map)).toList();
  }

  // =========== MealProducts part ============

  Future<List<MealProductModel>> getMealProducts(int mealId) async {
    final db = await _databaseService.database;
    final productMaps = await db.query('meal_products', where: 'meal_id = ?', whereArgs: [mealId]);
    return productMaps.map((map) => MealProductModel.fromJson(map)).toList();
  }

  Future<int> addProductToMeal(MealProductModel mealProduct, int userId, int mealId) async {
    final db = await _databaseService.database;
    mealProduct.userId ??= userId;
    mealProduct.mealId ??= mealId;
    return await db.insert('meal_products', mealProduct.toJson());
  }

  Future<int> updateMealProduct(MealProductModel mealProduct) async {
    final db = await _databaseService.database;
    return await db.update(
      'meal_products',
      mealProduct.toJson(),
      where: 'id = ?',
      whereArgs: [mealProduct.id],
    );
  }

  Future<int> deleteMealProduct(int mealProductId) async {
    final db = await _databaseService.database;
    return await db.delete('meal_products', where: 'id = ?', whereArgs: [mealProductId]);
  }
}
