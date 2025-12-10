import 'package:frontend/core/network/connectivity_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/services/product_api_service.dart';
import 'package:frontend/features/product/services/product_repository.dart';
import 'package:frontend/features/product/services/product_sync_service.dart';

class ProductService {
  final ProductRepository _productRepository;
  final ProductApiService _productApiService;
  final ProductSyncService _productSyncService;
  final CurrentUserService _currentUserService;
  final ConnectivityService _connectivityService;

  ProductService(
    this._productRepository,
    this._productApiService,
    this._productSyncService,
    this._currentUserService,
    this._connectivityService,
  );

  // ================== CRUD ===================
  Future<ProductModel> createCustomProduct(ProductModel customProduct) async {
    final userId = _currentUserService.getUserId();

    final savedProduct = await _productRepository.createCustomProduct(customProduct, userId);

    await _productSyncService.onCreate(savedProduct);

    // try to sync
    if (_connectivityService.isConnected) {
      await _productSyncService.syncToServer();
    }

    return savedProduct;
  }

  Future<void> updateCustomProduct(ProductModel customProduct) async {
    final userId = _currentUserService.getUserId();

    await _productRepository.updateCustomProduct(customProduct, userId);

    await _productSyncService.onUpdate(customProduct);

    // try to sync
    if (_connectivityService.isConnected) {
      await _productSyncService.syncToServer();
    }
  }

  Future<int> deleteCustomProduct(ProductModel customProduct) async {
    final userId = _currentUserService.getUserId();

    // 1. Do kolejki
    await _productSyncService.onDelete(customProduct.uuid);

    final result = await _productRepository.deleteCustomProduct(customProduct, userId);

    // try to sync
    if (_connectivityService.isConnected) {
      await _productSyncService.syncToServer();
    }

    return result;
  }

  // ================= Other ======================

  Future<List<ProductModel>> loadProducts() async {
    // TODO tu później zmienić żeby szukało z API a nie lokalnie ewentualnie jakoś łączyło to
    return _productRepository.getAllProducts();
  }

  Future<List<ProductModel>> loadCustomProducts() async {
    return _productRepository.getCustomProducts(_currentUserService.getUserId());
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) {
      return loadProducts();
    }
    return _productRepository.searchProducts(query);
  }
}
