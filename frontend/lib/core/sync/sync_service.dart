import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/core/network/connectivity_service.dart';

class SyncService {
  final ConnectivityService connectivityService;

  // final ProductSyncService _productSyncService;

  bool _isSyncing = false;

  SyncService({required this.connectivityService});

  void init() {
    connectivityService.onConnectivityRestored = syncAll;
    syncAll();
  }

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
      // await _productSyncService.syncAll();
      //
    } catch (e) {
      AppLogger.error("Sync failed: $e");
    } finally {
      _isSyncing = false;
    }
  }
}
