import 'dart:convert';

import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/core/sync/sync_operation.dart';
import 'package:frontend/core/sync/sync_queue_repository.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/services/meal_api_service.dart';
import 'package:frontend/features/meal/services/meal_repository.dart';

class MealSyncService {
  static const String featureName = 'meal';

  final MealRepository repository;
  final MealApiService apiService;
  final SyncQueueRepository syncQueueRepository;

  MealSyncService({required this.repository, required this.apiService, required this.syncQueueRepository});

  // Dla service

  Future<void> onCreate(MealProductModel mealProduct) async {
    await syncQueueRepository.add(
      SyncOperation(
        feature: featureName,
        operation: SyncOperationType.create,
        entityUuid: mealProduct.uuid,
        payload: mealProduct.toJson(),
      ),
    );
    AppLogger.debug('[MealSync] Queued CREATE: ${mealProduct.name}');
  }

  Future<void> onUpdate(MealProductModel mealProduct) async {
    final hasCreate = await syncQueueRepository.hasCreateOperation(mealProduct.uuid);

    if (hasCreate) {
      // Produkt nigdy nie był na serwerze
      final operations = await syncQueueRepository.getByEntityUuid(mealProduct.uuid);

      for (var op in operations) {
        await syncQueueRepository.updatePayload(op.id!, mealProduct.toJson());
        AppLogger.debug('[MealSync] Updated CREATE payload: ${mealProduct.name}');
        return;
      }
    }

    // Produkt był na serwerze
    await syncQueueRepository.removeByEntityUuidAndOperation(mealProduct.uuid, SyncOperationType.update);

    await syncQueueRepository.add(
      SyncOperation(
        feature: featureName,
        operation: SyncOperationType.update,
        entityUuid: mealProduct.uuid,
        payload: mealProduct.toJson(),
      ),
    );
    AppLogger.debug('[MealSync] Queued UPDATE: ${mealProduct.name}');
  }

  Future<void> onDelete(String uuid) async {
    final hasCreate = await syncQueueRepository.hasCreateOperation(uuid);

    if (hasCreate) {
      // Produkt nigdy nie był na serwerze
      await syncQueueRepository.removeByEntityUuid(uuid);
      AppLogger.debug('[MealSync] Removed CREATE operation for: $uuid');
      return;
    }

    // Produkt był na serwerze
    await syncQueueRepository.removeByEntityUuidAndOperation(uuid, SyncOperationType.delete);

    await syncQueueRepository.add(
      SyncOperation(
        feature: featureName,
        operation: SyncOperationType.delete,
        entityUuid: uuid,
        payload: null,
      ),
    );
    AppLogger.debug('[MealSync] Queued DELETE: $uuid');
  }

  // Synchronizacja
  Future<void> syncToServer() async {
    final operations = await syncQueueRepository.getByFeature(featureName);

    if (operations.isEmpty) {
      AppLogger.debug('[MealSync] Nothing to sync');
      return;
    }

    AppLogger.info('[MealSync] Syncing ${operations.length} operations to server...');

    for (final op in operations) {
      try {
        await _processOperation(op);
        await syncQueueRepository.remove(op.id!);
        AppLogger.debug('[MealSync] Done: ${op.operation.name} ${op.entityUuid}');
      } catch (e) {
        AppLogger.error('[MealSync] Failed: ${op.operation.name} ${op.entityUuid}: $e');
      }
    }
  }

  Future<void> _processOperation(SyncOperation op) async {
    AppLogger.debug('[MealSync] Processing ${op.operation.name}: ${op.payload}');

    switch (op.operation) {
      case SyncOperationType.create:
        final response = await apiService.createMealProduct(op.payload!);

        AppLogger.debug('[MealSync] Create response: ${response.statusCode} - ${response.body}');
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('API ${response.statusCode}: ${response.body}');
        }
        await repository.markAsSynced(op.entityUuid);

      case SyncOperationType.update:
        final response = await apiService.updateMealProduct(op.payload!);
        AppLogger.debug('[MealSync] Update response: ${response.statusCode} - ${response.body}');
        if (response.statusCode != 200) {
          throw Exception('API ${response.statusCode}: ${response.body}');
        }
        await repository.markAsSynced(op.entityUuid);

      case SyncOperationType.delete:
        final response = await apiService.deleteMealProduct(op.entityUuid);
        AppLogger.debug('[MealSync] Delete response: ${response.statusCode} - ${response.body}');
        if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 404) {
          throw Exception('API ${response.statusCode}: ${response.body}');
        }
    }
  }

  Future<void> syncFromServer(int userId) async {
    AppLogger.info('[MealSync] Starting sync from server for userId: $userId');

    try {
      final response = await apiService.getUserMealProducts();
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch meal products from server: ${response.body}');
      }

      final List<dynamic> mealProductsJson = jsonDecode(response.body);
      AppLogger.info('[MealSync] Received ${mealProductsJson.length} products from server');

      for (final json in mealProductsJson) {
        final mealProduct = MealProductModel.fromJson(json);

        final existingMealProduct = await repository.getByUuid(mealProduct.uuid);

        if (existingMealProduct == null) {
          await repository.insertFromServer(mealProduct, userId);
          AppLogger.debug('[MealSync] Inserted ${mealProduct.name}');
        } else {
          if (mealProduct.lastModifiedAt.isAfter(existingMealProduct.lastModifiedAt)) {
            await repository.updateFromServer(mealProduct);
            AppLogger.debug('[MealSync] Updated: ${mealProduct.name}');
          }
        }
      }

      AppLogger.info('[MealSync] Sync from server completed');
    } catch (e) {
      AppLogger.error('[MealSync] Sync from server failed: $e');
    }
  }
}
