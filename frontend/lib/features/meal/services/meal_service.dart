import 'package:flutter/material.dart'; // Wymagane dla ChangeNotifier
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/core/network/connectivity_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/services/meal_repository.dart';
import 'package:frontend/features/meal/services/meal_sync_service.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:uuid/uuid.dart';

class MealService with ChangeNotifier {
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

  Future<MealProductModel> addMealProduct(MealProductModel mealProduct) async {
    final userId = _currentUserService.getUserId();
    final savedMealProduct = await _mealRepository.addMealProduct(mealProduct, userId);

    await _mealSyncService.onCreate(savedMealProduct);

    if (_connectivityService.isConnected) {
      _mealSyncService.syncToServer();
    }

    notifyListeners(); // Powiadomienie o zmianie danych
    return savedMealProduct;
  }

  Future<void> updateMealProduct(MealProductModel mealProduct) async {
    final userId = _currentUserService.getUserId();
    await _mealRepository.updateMealProduct(mealProduct, userId);
    await _mealSyncService.onUpdate(mealProduct);

    if (_connectivityService.isConnected) {
      await _mealSyncService.syncToServer();
    }

    notifyListeners(); // Powiadomienie o zmianie danych
  }

  Future<int> deleteMealProduct(MealProductModel mealProduct) async {
    final userId = _currentUserService.getUserId();
    await _mealSyncService.onDelete(mealProduct.uuid);
    final result = await _mealRepository.deleteMealProduct(mealProduct, userId);

    if (_connectivityService.isConnected) {
      await _mealSyncService.syncToServer();
    }

    notifyListeners(); // Powiadomienie o zmianie danych
    return result;
  }

  Future<List<MealProductModel>> getMealProductsForDate(DateTime date) async {
    final userId = _currentUserService.getUserId();
    return await _mealRepository.getMealProductsForDate(date, userId);
  }

  Future<List<MealProductModel>> addMealProductsFromAI(
    List<Map<String, dynamic>> aiProducts,
    DateTime date,
  ) async {
    final userId = _currentUserService.getUserId();
    final addedProducts = <MealProductModel>[];

    for (final item in aiProducts) {
      final product = item['product'] as ProductModel;
      final weight = item['weight'] as double;
      final multiplier = weight / 100.0;

      final mealProduct = MealProductModel(
        uuid: const Uuid().v4(),
        productUuid: product.uuid,
        name: product.name,
        manufacturer: product.manufacturer,
        kcal: (product.kcal * multiplier).round(),
        carbs: product.carbs * multiplier,
        protein: product.protein * multiplier,
        fat: product.fat * multiplier,
        unitId: 1,
        unitShort: 'g',
        conversionFactor: 1.0,
        amount: weight,
        notes: 'Added via AI detection',
        createdAt: date,
        lastModifiedAt: DateTime.now(),
      );

      final saved = await _mealRepository.addMealProduct(mealProduct, userId);
      addedProducts.add(saved);
      await _mealSyncService.onCreate(saved);
    }

    if (_connectivityService.isConnected) {
      _mealSyncService.syncToServer();
    }

    notifyListeners(); // Powiadomienie o zmianie danych
    return addedProducts;
  }
}
