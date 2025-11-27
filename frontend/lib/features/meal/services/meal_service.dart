import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/services/meal_api_service.dart';
import 'package:frontend/features/meal/services/meal_repository.dart';

class MealService {
  final MealApiService _mealApiService;
  final MealRepository _mealRepository;
  final CurrentUserService _currentUserService;

  MealService(this._mealApiService, this._mealRepository, this._currentUserService);

  int _getUserId() {
    final userId = _currentUserService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    return userId;
  }

  Future<List<MealModel>> loadMealsByDate(DateTime date) async {
    final userId = _getUserId();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await _mealRepository.getMealsByDateRange(userId, startOfDay, endOfDay);
  }

  Future<List<MealProductModel>> loadMealProducts(int mealId) async {
    return await _mealRepository.getMealProducts(mealId);
  }

  Future<int> addMeal(MealModel meal) async {
    final userId = _getUserId();
    final mealToAdd = meal.copyWith(userId: userId);
    return await _mealRepository.addMeal(mealToAdd, userId);
  }

  Future<int> updateMeal(MealModel meal) async {
    return await _mealRepository.updateMeal(meal);
  }

  Future<int> addProductToMeal(MealProductModel mealProduct, int mealId) async {
    final userId = _getUserId();
    final productToAdd = mealProduct.copyWith(userId: userId);
    return await _mealRepository.addProductToMeal(productToAdd, userId, mealId);
  }

  Future<int> deleteMeal(int mealId) async {
    return await _mealRepository.deleteMeal(mealId);
  }
}
