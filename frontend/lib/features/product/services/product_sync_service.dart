import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/core/sync/sync_operation.dart';
import 'package:frontend/core/sync/sync_queue_repository.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/services/product_api_service.dart';
import 'package:frontend/features/product/services/product_repository.dart';
import 'dart:convert';

class ProductSyncService {
  static const String featureName = 'product';

  final ProductRepository repository;
  final ProductApiService apiService;
  final SyncQueueRepository syncQueueRepository;

  ProductSyncService({required this.repository, required this.apiService, required this.syncQueueRepository});

  // Metody dla ProductService

  Future<void> onCreate(ProductModel product) async {
    await syncQueueRepository.add(
      SyncOperation(
        feature: featureName,
        operation: SyncOperationType.create,
        entityUuid: product.uuid,
        payload: product.toJson(),
      ),
    );
    AppLogger.debug('[ProductSync] Queued CREATE: ${product.name}');
  }

  Future<void> onUpdate(ProductModel product) async {
    final hasCreate = await syncQueueRepository.hasCreateOperation(product.uuid);

    if (hasCreate) {
      // Produkt nigdy nie był na serwerze
      final operations = await syncQueueRepository.getByEntityUuid(product.uuid);

      for (var op in operations) {
        await syncQueueRepository.updatePayload(op.id!, product.toJson());
        AppLogger.debug('[ProductSync] Updated CREATE payload: ${product.name}');
        return;
      }
    }

    // Produkt był na serwerze
    await syncQueueRepository.removeByEntityUuidAndOperation(product.uuid, SyncOperationType.update);

    await syncQueueRepository.add(
      SyncOperation(
        feature: featureName,
        operation: SyncOperationType.update,
        entityUuid: product.uuid,
        payload: product.toJson(),
      ),
    );
    AppLogger.debug('[ProductSync] Queued UPDATE: ${product.name}');
  }

  Future<void> onDelete(String uuid) async {
    final hasCreate = await syncQueueRepository.hasCreateOperation(uuid);

    if (hasCreate) {
      // Produkt nigdy nie był na serwerze czyli wystarczy usunąć lokalne operacje z kolejki
      await syncQueueRepository.hasCreateOperation(uuid);
      AppLogger.debug('[ProductSync] Removed queued ops for never-synced: $uuid');
    } else {
      // Produkt był na serwerze
      await syncQueueRepository.removeByEntityUuid(uuid);
      await syncQueueRepository.add(
        SyncOperation(
          feature: featureName,
          operation: SyncOperationType.delete,
          entityUuid: uuid,
          payload: null,
        ),
      );
      AppLogger.debug('[ProductSync] Queued DELETE: $uuid');
    }
  }

  // Synchronizacja

  Future<void> syncToServer() async {
    final operations = await syncQueueRepository.getByFeature(featureName);

    if (operations.isEmpty) {
      AppLogger.debug('[ProductSync] Nothing to sync');
      return;
    }

    AppLogger.info('[ProductSync] Syncing ${operations.length} operations...');

    for (final op in operations) {
      try {
        await _processOperation(op);
        await syncQueueRepository.remove(op.id!);
      } catch (e) {
        AppLogger.error('[ProductSync] Failed: ${op.operation.name} ${op.entityUuid}: $e');
      }
    }
  }

  Future<void> _processOperation(SyncOperation op) async {
    switch (op.operation) {
      case SyncOperationType.create:
        final response = await apiService.createProduct(op.payload!);
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('API Error: ${response.statusCode}: ${response.body}');
        }
        await repository.markAsSynced(op.entityUuid);

      case SyncOperationType.update:
        final response = await apiService.updateProduct(op.entityUuid, op.payload!);
        if (response.statusCode != 200) {
          throw Exception('API ${response.statusCode}: ${response.body}');
        }
        await repository.markAsSynced(op.entityUuid);

      case SyncOperationType.delete:
        final response = await apiService.deleteProduct(op.entityUuid);
        if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 404) {
          throw Exception('API ${response.statusCode}: ${response.body}');
        }
    }
  }

  Future<void> syncFromServer(int userId) async {
    AppLogger.info('[ProductSync] Syncing from server...');

    try {
      final response = await apiService.getUserProducts();

      if (response.statusCode != 200) {
        throw Exception('API ${response.statusCode}: ${response.body}');
      }

      final List<dynamic> productsJson = jsonDecode(response.body);
      AppLogger.info('[ProductSync] Received ${productsJson.length} products from server');

      for (final productJson in productsJson) {
        final product = ProductModel.fromJson(productJson);

        // Czy produkt już istnieje lokalnie
        final existingProduct = await repository.getByUuid(product.uuid);

        if (existingProduct == null) {
          // Nowy produkt
          await repository.insertFromServer(product, userId);
          AppLogger.debug('[ProductSync] Inserted: ${product.name}');
        } else {
          // Istnieje
          if (product.lastModifiedAt.isAfter(existingProduct.lastModifiedAt)) {
            await repository.updateFromServer(product);
            AppLogger.debug('[ProductSync] Updated: ${product.name}');
          }
        }
      }

      AppLogger.info('[ProductSync] Sync from server completed');
    } catch (e) {
      AppLogger.error('[ProductSync] Sync from server failed: $e');
      rethrow;
    }
  }
}
