import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/core/network/connectivity_service.dart';
import 'package:frontend/features/meal/services/meal_sync_service.dart';
import 'package:frontend/features/product/services/product_sync_service.dart';

class SyncService {
  final ConnectivityService connectivityService;

  final ProductSyncService productSyncService;
  final MealSyncService mealSyncService;

  bool _isSyncing = false;

  SyncService({
    required this.connectivityService,
    required this.productSyncService,
    required this.mealSyncService,
  });

  void init() {
    connectivityService.onConnectivityRestored = syncAll;
    syncAll();
  }

  // Lokalne zmiany na serwer
  Future<void> syncAll() async {
    if (_isSyncing) {
      return;
    }

    if (!connectivityService.isConnected) {
      AppLogger.warning("No connection - skipping sync");
      return;
    }

    _isSyncing = true;
    AppLogger.info("Starting sync");

    try {
      await productSyncService.syncToServer();
      await mealSyncService.syncToServer();
      // ...
    } catch (e) {
      AppLogger.error("Sync failed: $e");
    } finally {
      _isSyncing = false;
    }
  }

  // Dane z serwea np przy logowaniu
  Future<void> syncFromServer(int userId) async {
    if (!connectivityService.isConnected) {
      AppLogger.warning("No connection - skipping sync from server");
      return;
    }

    AppLogger.info("[Sync] Starting sync from server...");

    try {
      await productSyncService.syncFromServer(userId);
      await mealSyncService.syncFromServer(userId);
      // ...

      AppLogger.info("[Sync] Sync from server completed");
    } catch (e) {
      AppLogger.error("[Sync] Sync from server failed: $e");
    }
  }

  Future<void> fullSync(int userId) async {
    // 1. Lokalne -> serwer
    await syncAll();

    // 2. Server -> lokalne
    await syncFromServer(userId);
  }
}
