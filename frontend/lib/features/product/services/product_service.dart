import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/services/product_repository.dart';

class ProductService {
  final ProductRepository _productRepository;

  ProductService(this._productRepository);

  Future<List<ProductModel>> loadProducts() async {
    // TODO tu później zmienić żeby szukało z API a nie lokalnie ewentualnie jakoś łączyło to
    return _productRepository.getAllProducts();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) {
      return loadProducts();
    }
    return _productRepository.searchProducts(query);
  }
}
