import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/services/product_repository.dart';

class ProductService {
  final ProductRepository _productRepository;
  final CurrentUserService _currentUserService;

  ProductService(this._productRepository, this._currentUserService);

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

  Future<ProductModel> addCustomProduct(ProductModel customProduct) async {
    final userId = _currentUserService.getUserId();
    return await _productRepository.createCustomProduct(customProduct, userId);
  }
}
