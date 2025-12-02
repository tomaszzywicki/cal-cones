import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/services/meal_api_service.dart';
import 'package:frontend/features/meal/services/meal_repository.dart';

class MealService {
  final MealApiService _mealApiService;
  final CurrentUserService _currentUserService;
  final MealRepository _mealRepository;

  MealService(this._mealApiService, this._currentUserService, this._mealRepository);

  Future<List<MealProductModel>> getMealProductsForDate(DateTime date) async {
    final userId = _currentUserService.getUserId();
    return await _mealRepository.getMealProductsForDate(date, userId);
  }

  Future<void> addMealProduct(MealProductModel mealProduct) async {
    final userId = _currentUserService.getUserId();
    await _mealRepository.addMealProduct(mealProduct, userId);
  }

  Future<void> updateMealProduct(MealProductModel mealProduct) async {
    final userId = _currentUserService.getUserId();
    await _mealRepository.updateMealProduct(mealProduct, userId);
  }

  Future<void> deleteMealProduct(MealProductModel mealProduct) async {
    final userId = _currentUserService.getUserId();
    await _mealRepository.deleteMealProduct(mealProduct.id!, userId);
  }
}
