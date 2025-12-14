import 'package:frontend/core/network/connectivity_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/services/meal_repository.dart';
import 'package:frontend/features/meal/services/meal_sync_service.dart';

class MealService {
  final MealRepository _mealRepository;
  final MealSyncService _mealSyncService;
  final CurrentUserService _currentUserService;
  final ConnectivityService _connectivityService;

  MealService(
    this._mealRepository,
    this._mealSyncService,
    this._currentUserService,
    this._connectivityService,
  );

  // ======================== CRUD ==============================

  Future<MealProductModel> addMealProduct(MealProductModel mealProduct) async {
    final userId = _currentUserService.getUserId();

    final savedMealProduct = await _mealRepository.addMealProduct(mealProduct, userId);

    await _mealSyncService.onCreate(savedMealProduct);

    if (_connectivityService.isConnected) {
      _mealSyncService.syncToServer();
    }

    return savedMealProduct;
  }

  Future<void> updateMealProduct(MealProductModel mealProduct) async {
    final userId = _currentUserService.getUserId();

    await _mealRepository.updateMealProduct(mealProduct, userId);

    await _mealSyncService.onUpdate(mealProduct);

    if (_connectivityService.isConnected) {
      await _mealSyncService.syncToServer();
    }
  }

  Future<int> deleteMealProduct(MealProductModel mealProduct) async {
    final userId = _currentUserService.getUserId();

    // 1. Do kolejki
    await _mealSyncService.onDelete(mealProduct.uuid);

    final result = await _mealRepository.deleteMealProduct(mealProduct, userId);

    // try to sync
    if (_connectivityService.isConnected) {
      await _mealSyncService.syncToServer();
    }

    return result;
  }

  Future<List<MealProductModel>> getMealProductsForDate(DateTime date) async {
    final userId = _currentUserService.getUserId();
    return await _mealRepository.getMealProductsForDate(date, userId);
  }
}
