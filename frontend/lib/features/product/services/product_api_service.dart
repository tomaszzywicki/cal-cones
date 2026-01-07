import 'package:frontend/core/network/api_client.dart';
import 'package:http/http.dart' as http;

class ProductApiService extends ApiClient {
  ProductApiService(super.firebaseAuthService);

  static const String name = 'product';

  Future<http.Response> createProduct(Map<String, dynamic> data) {
    return post('/$name/create', data);
  }

  Future<http.Response> updateProduct(String uuid, Map<String, dynamic> data) {
    return put('/$name/update', data);
  }

  Future<http.Response> deleteProduct(String uuid) {
    return delete('/$name/delete/$uuid');
  }

  Future<http.Response> searchProducts(String query) {
    return get('/$name/search/$query');
  }

  Future<http.Response> getUserProducts() {
    return get('/$name/added/');
  }
}
