import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/services/meal_api_service.dart';
import 'package:frontend/features/meal/services/meal_repository.dart';

class MealService {
  final MealApiService _mealApiService;
  final MealRepository _mealRepository;
  final CurrentUserService currentUserService;

  MealService(this._mealApiService, this._mealRepository, this.currentUserService);

  Future<List<MealProductModel>> loadMealProducts(int mealId) async {
    // TODO add implementation
    return [];
  }
}
